module "vpc" {
  source = "./modules/vpc"

  for_each = local.vpcs

  az_override      = local.az_override
  azs              = local.azs
  enable_igw       = each.value.enable_igw
  enable_natgw     = each.value.enable_natgw

  default_rtb_tags = each.value.default_rtb_tags
  vpc_name         = each.key
  vpc_cidr         = each.value.vpc_cidr
  vpc_tags         = each.value.vpc_tags
  types            = each.value.types
}

module "alb" {
  depends_on = [ module.vpc ]
  
  source = "./modules/alb"

  for_each = local.albs

  vpc_id                      = module.vpc[each.value.vpc_name].vpc_id
  subnet_ids                  = each.value.internal ? module.vpc[each.value.vpc_name].private_subnet_ids : module.vpc[each.value.vpc_name].public_subnet_ids

  name                        = each.key
  alb_tags                    = each.value.alb_tags
  internal                    = each.value.internal
  port                        = each.value.port
  protocol                    = each.value.protocol
  target_groups               = each.value.target_groups
  listener_target_groups      = each.value.listener_target_groups

  security_group_name         = each.value.security_group_name
  security_group_tags         = each.value.security_group_tags
  ingress_ports               = each.value.ingress_ports
  egress_ports                = each.value.egress_ports

  enable_attach_target        = each.value.enable_attach_target
  targets                     = each.value.targets
  # ec2_info                    = each.value.enable_attach_target ? {for t in each.value.targets : t.target_name => module.ec2[t.target_name].ec2_instance_id} : {}
}

module "ecr" {
  source = "./modules/ecr"

  for_each = local.ecrs

  name                     = each.key
  tags                     = each.value.tags
  image_tag_mutability     = each.value.image_tag_mutability
  force_delete             = each.value.force_delete
  scan_images_on_push      = each.value.scan_images_on_push

  encryption_configuration = each.value.enable_kms ? {
    encryption_type = each.value.encryption_type
    kms_key = null
  } : null
  image_tag_mutability_exclusion_filter = each.value.enable_image_tag_exclusion_filter ? each.value.image_tag_exclusion_filter : []
}

module "ecs" {
  depends_on = [ module.vpc ]

  source = "./modules/ecs"

  for_each = local.ecss

  vpc_id                          = module.vpc[each.value.vpc_name].vpc_id
  subnet_ids                      = each.value.internal ? module.vpc[each.value.vpc_name].private_subnet_ids : module.vpc[each.value.vpc_name].public_subnet_ids
  
  cluster_name                    = each.key
  cluster_tags                    = each.value.cluster_tags
  internal                        = each.value.internal
  cluster_container_insights      = each.value.cluster_container_insights
  enable_load_balancers           = each.value.enable_load_balancers
  taskdefinition                  = each.value.taskdefinition
  service                         = each.value.service
  target_group_arns               = {for svc_name, svc in each.value.service :svc.load_balancers[0].target_group_name => module.alb[svc.elb_name].alb_target_group_arns[svc.load_balancers[0].target_group_name]}
  # target_group_arns               = null
  
  security_group_name             = each.value.security_group_name
  security_group_tags             = each.value.security_group_tags
  ingress_ports                   = each.value.ingress_ports
  egress_ports                    = each.value.egress_ports
  
  enable_create_iam_role          = each.value.enable_create_iam_role
  iam_task_role_name              = each.value.iam_task_role_name
  iam_task_policies               = each.value.iam_task_policies
  iam_task_role_tags              = each.value.iam_task_role_tags

  iam_exec_role_name              = each.value.iam_exec_role_name
  iam_exec_role_tags              = each.value.iam_exec_role_tag
  iam_exec_policies               = each.value.iam_exec_policies
  
  statements                      = each.value.statements
  iam_exec_policy_name            = each.value.iam_exec_policy_name
  iam_exec_policy_tags            = each.value.iam_exec_policy_tags
  
  iam_ec2_role_name               = each.value.iam_ec2_role_name
  iam_ec2_role_tags               = each.value.iam_ec2_role_tags
  iam_ec2_policies                = each.value.iam_ec2_policies
  instance_profile_name           = each.value.instance_profile_name
  
  app_ecr_url                     = {for c_name, c in each.value.containers : c_name => module.ecr[c.app_ecr_name].repository_url}
  log_ecr_url                     = {for c_name, c in each.value.containers : c_name => c.enable_fluentbit ? module.ecr[c.log_ecr_name].repository_url : null}
  # app_ecr_url                     = null
  # log_ecr_url                     = null

  opensearch_host                 = null
  containers                      = each.value.containers
  enable_secrets_manager          = each.value.enable_secrets_manager
  # secrets_manager_arn             = {for c_name, c in each.value.containers : c.secrets_manager_name => module.secrets_manager[c.secrets_manager_name].secrets_manager_arn if c.enable_secrets_manager}
  secrets_manager_arn             = null
}