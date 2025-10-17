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

module "rds" {
  depends_on = [ module.vpc ]

  source = "./modules/rds"

  for_each = local.rdss

  vpc_id                         = module.vpc[each.value.vpc_name].vpc_id
  protect_subnet_ids             = module.vpc[each.value.vpc_name].protect_subnet_ids
  availability_zones             = local.azs
  name                           = each.key
  rds_cluster_tags               = each.value.rds_cluster_tags
  instance_name                  = each.value.instance_name
  instance_tags                  = each.value.instance_tags

  db_name                        = each.value.db_name
  cw_logs_exports                = each.value.cw_logs_exports
  engine                         = each.value.engine
  user_name                      = each.value.user_name
  user_password                  = each.value.user_password
  port                           = each.value.port
  backtrack_window               = each.value.backtrack_window
  skip_final_snapshot            = each.value.skip_final_snapshot
  storage_encrypted              = each.value.storage_encrypted
  performance_insights_enabled   = each.value.performance_insights_enabled

  instance_count                 = each.value.instance_count
  instance_class                 = each.value.instance_class
  instance_engine                = each.value.instance_engine

  subnet_group_name              = each.value.subnet_group_name
  subnet_group_tags              = each.value.subnet_group_tags

  cluster_parameter_group_name   = each.value.cluster_parameter_group_name
  cluster_parameter_group_family = each.value.cluster_parameter_group_family
  parameters                     = each.value.parameters
  cluster_parameter_group_tags   = each.value.cluster_parmeter_group_tags

  parameter_group_name           = each.value.parameter_group_name
  parameter_group_family         = each.value.parameter_group_family
  parameter_group_tags           = each.value.parameter_group_tags

  security_group_name            = each.value.security_group_name
  security_group_tags            = each.value.security_group_tags
  ingress_ports                  = each.value.ingress_ports
  egress_ports                   = each.value.egress_ports
}

module "secrets_manager" {
  source = "./modules/secrets-manager"

  for_each = local.secrets_managers

  name = each.value.name

  secret_values = {
    DB_USER     = module.rds[each.value.rds_name].rds_user_name
    DB_PASSWORD = module.rds[each.value.rds_name].rds_user_password
    DB_ADDRESS  = module.rds[each.value.rds_name].rds_address
    DB_PORT     = module.rds[each.value.rds_name].rds_port
    DB_NAME     = module.rds[each.value.rds_name].rds_db_name
  }
}