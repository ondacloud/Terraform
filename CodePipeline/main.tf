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

  default_action              = each.value.default_action
  enable_listener_rules       = each.value.enable_listener_rules
  listener_rules              = each.value.listener_rules

  target_groups               = each.value.target_groups

  security_group_name         = each.value.security_group_name
  security_group_tags         = each.value.security_group_tags
  ingress_ports               = each.value.ingress_ports
  egress_ports                = each.value.egress_ports

  enable_attach_target        = each.value.enable_attach_target
  targets                     = each.value.targets
  # target_info                 = each.value.enable_attach_target ? {for t in each.value.targets : t.target_name => module.ec2[t.target_name].ec2_instance_id} : {}
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
    # kms_key = module.kms[each.value.kms_key_name].kms_arn
    kms_key = null
  } : null
  image_tag_mutability_exclusion_filter = each.value.enable_image_tag_exclusion_filter ? each.value.image_tag_exclusion_filter : []
}

module "codebuild" {
  source = "./modules/codebuild"

  for_each = local.codebuilds

  name                              = each.key
  tags                              = each.value.tags
  github_access_token               = local.github.access_token

  artifact_type                     = each.value.artifact_type
  
  enable_cache                      = each.value.enable_cache
  cache                             = each.value.cache_config
  
  build_compute_type                = each.value.build_compute_type
  build_image                       = each.value.build_image
  build_image_pull_credentials_type = each.value.build_image_pull_credentials_type  
  build_type                        = each.value.build_type
  privileged_mode                   = each.value.privileged_mode

  buildspec                         = each.value.buildspec
  source_type                       = each.value.source_type
  source_location                   = each.value.source_location
  report_build_status               = each.value.report_build_status

  enable_environment_variable       = each.value.enable_environment_variable
  environment_variables             = each.value.environment_variables

  enable_vpc_config                 = each.value.enable_vpc_config
  # vpc_config = each.value.enable_vpc_config ? {
  #   vpc_id  = module.vpc[each.value.vpc_name].vpc_id
  #   subnets = each.value.internal ? module.vpc[each.value.vpc_name].private_subnet_ids : module.vpc[each.value.vpc_name].public_subnet_ids
  # } : null
  vpc_config                         = null
  
  security_group_name               = each.value.security_group_name
  security_group_tags               = each.value.security_group_tags
  ingress_ports                     = each.value.ingress_ports
  egress_ports                      = each.value.egress_ports

  enable_logs                       = each.value.enable_logs
  logs_config                       = each.value.logs_config

  enable_file_system                = each.value.enable_file_system
  # file_system_locations = each.value.enable_vpc_config && each.value.enable_file_system ? [
  #   {
  #     identifier    = module.efs[each.value.efs_name].efs_id
  #     location      = "${module.efs[each.value.efs_name].efs_dns_name}:${each.value.mount_path}"
  #     mount_point   = each.value.mount_point
  #   }
  # ] : []
  file_system_locations             = null

  iam_role_name                     = each.value.role_name
  role_tags                         = each.value.role_tags
  iam_role_arn                      = each.value.iam_role_arn
  statements                        = each.value.statements
  enable_iam_role                   = each.value.enable_iam_role
  policy_name                       = each.value.policy_name
  policy_tags                       = each.value.policy_tags
}

module "codedeploy" {
  source = "./modules/codedeploy"

  for_each = local.codedeploys

  app_name                            = each.key
  app_tags                            = each.value.app_tags

  compute_platform                    = each.value.compute_platform
  deployment_config_name              = each.value.deployment_config_name
  
  deployment_group_name               = each.value.deployment_group_name
  deployment_group_tags               = each.value.deployment_group_tags
  
  outpdated_instances_strategy        = each.value.outpdated_instances_strategy
  auto_rollback_configuration_enabled = each.value.auto_rollback_configuration_enabled
  auto_rollback_configuration_events  = each.value.auto_rollback_configuration_events

  deployment_style                    = each.value.deployment_style
  ec2_tag_set                         = each.value.compute_platform == "Server" ? lookup(each.value, "ec2_tag_set", []) : []

  minimum_healthy_hosts               = lookup(each.value, "minimum_healthy_hosts", null)
  traffic_routing_config              = lookup(each.value, "traffic_routing_config", null)
  blue_green_deployment_config        = each.value.compute_platform == "ECS" ? lookup(each.value, "blue_green_deployment_config", null) : null
  ecs_service                         = each.value.compute_platform == "ECS" ? lookup(each.value, "ecs_service", []) : []
  load_balancer_info                  = lookup(each.value, "load_balancer_info", null)

  enable_iam_role                     = each.value.enable_iam_role
  iam_role_name                       = each.value.iam_role_name
  iam_role_tags                       = each.value.iam_role_tags
  statements                          = each.value.statements
  iam_policy_name                     = each.value.iam_policy_name
  iam_policy_tags                     = each.value.iam_policy_tags
}

module "codepipeline" {
  depends_on = [ module.codebuild, module.codedeploy ]

  source = "./modules/codepipeline"

  for_each = local.codepipelines

  name                             = each.key
  tags                             = each.value.tags
  pipeline_type                    = each.value.pipeline_type
  bucket_name                      = each.value.bucket_name
  
  enable_source_github             = each.value.enable_source_github
  source_github_configuration      = each.value.source_github_configuration
  
  enable_source_s3                 = each.value.enable_source_s3
  source_s3_configuration          = each.value.source_s3_configuration
  
  enable_build                     = each.value.enable_build
  enable_codebuild                 = each.value.enable_codebuild
  codebuild_name                   = each.value.enable_build ? module.codebuild[each.value.codebuild_name].codebuild_name : null
  enable_approval                  = each.value.enable_approval
  
  enable_deploy                    = each.value.enable_deploy
  
  enable_deploy_ec2                = each.value.enable_deploy_ec2
  deploy_ec2_configuration         = each.value.deploy_ec2_configuration
  
  enable_deploy_ecs                = each.value.enable_deploy_ecs
  deploy_ecs_configuration         = each.value.deploy_ecs_configuration

  iam_role_name                    = each.value.role_name
  role_tags                        = each.value.role_tags
  iam_role_arn                     = each.value.iam_role_arn
  statements                       = each.value.statements
  enable_iam_role                  = each.value.enable_iam_role
  policy_name                      = each.value.policy_name
  policy_tags                      = each.value.policy_tags
}