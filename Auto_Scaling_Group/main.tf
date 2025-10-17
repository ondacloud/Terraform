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

module "launch_template" {
  depends_on = [ module.vpc ]
  
  source = "./modules/launch_template"

  for_each = local.launch_templates

  vpc_id                 = module.vpc[each.value.vpc_name].vpc_id

  name                   = each.key
  tags                   = each.value.tags
  enable_monitoring      = each.value.enable_monitoring
  instance_type          = each.value.instance_type
  userdata               = each.value.userdata
  block_device_mappings  = each.value.block_device_mappings
  tag_specifications     = each.value.tag_specifications

  security_group_name    = each.value.security_group_name
  ingress_ports          = each.value.ingress_ports
  egress_ports           = each.value.egress_ports

  enable_create_keypair  = each.value.enable_create_keypair
  keypair_name           = each.value.keypair_name
  keypair_file_path      = each.value.keypair_file_path

  enable_create_iam_role = each.value.enable_create_iam_role
  iam_role_name          = each.value.iam_role_name
  instance_profile_name  = each.value.instance_profile_name
  iam_policies           = each.value.iam_policies
}

module "auto_scaling_group" {
  depends_on = [ module.vpc, module.launch_template, module.alb ]

  source = "./modules/auto_scaling_group"

  for_each = local.asgs
  
  subnet_ids                  = each.value.internal ? module.vpc[each.value.vpc_name].private_subnet_ids : module.vpc[each.value.vpc_name].public_subnet_ids

  name                        = each.key
  tags                        = each.value.tags
  launch_template_id          = module.launch_template[each.value.launch_template_name].launch_template_id
  tags_no_launch              = each.value.tags_no_launch
  desired_capacity            = each.value.desired_capacity
  min_size                    = each.value.min_size
  max_size                    = each.value.max_size
  health_check_type           = each.value.health_check_type
  health_check_grace_period   = each.value.health_check_grace_period
  timeout_delete_time         = each.value.timeout_delete_time
  enable_scaling_policy       = each.value.enable_scaling_policy
  scaling_policys             = each.value.scaling_policys
  enable_attach_elb           = each.value.enable_attach_elb
  # elb_arn_suffix              = module.alb[each.value.elb_name].alb_arn_suffix
  # elb_target_group_arn        = module.alb[each.value.elb_name].alb_target_group_arns[each.value.elb_target_group_name]
  # elb_target_group_arn_suffix = module.alb[each.value.elb_name].alb_target_group_arn_suffixs[each.value.elb_target_group_name]
}
