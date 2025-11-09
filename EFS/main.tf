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

module "kms" {
  source = "./modules/kms"

  for_each = local.kmss

  name                    = each.key
  tags                    = each.value.tags
  alias_name              = each.value.alias_name
  key_usage               = each.value.key_usage
  deletion_window_in_days = each.value.deletion_window_in_days
}

module "efs" {
  depends_on = [ module.vpc ]
  source = "./modules/efs"

  for_each = local.efss

  vpc_id                          = module.vpc[each.value.vpc_name].vpc_id
  subnet_ids                      = module.vpc[each.value.vpc_name].private_subnet_ids

  name                            = each.key
  tags                            = each.value.tags
  performance_mode                = each.value.performance_mode
  encrypted                       = each.value.encrypted
  # kms_key_id                      = each.value.encrypted ? module.kms[each.value.kms_key_name].kms_arn : each.value.encrypted
  kms_key_id                      = null
  provisioned_throughput_in_mibps = each.value.provisioned_throughput_in_mibps
  throughput_mode                 = each.value.throughput_mode
  enable_backup_policy            = each.value.enable_backup_policy
  security_group_name             = each.value.security_group_name
  security_group_tags             = each.value.security_group_tags
  ingress_ports                   = each.value.ingress_ports
  egress_ports                    = each.value.egress_ports
}