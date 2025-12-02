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

  iam_role_name                     = each.value.iam_role_name
  iam_role_tags                     = each.value.iam_role_tags
  iam_role_arn                      = each.value.iam_role_arn
  statements                        = each.value.statements
  enable_iam_role                   = each.value.enable_iam_role
  policy_name                       = each.value.iam_policy_name
  policy_tags                       = each.value.iam_policy_tags
}