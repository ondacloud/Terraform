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
module "elaticache" {
  depends_on = [ module.vpc ]
  
  source = "./modules/elaticache"

  for_each = local.elaticaches

  vpc_id                        = module.vpc[each.value.vpc_name].vpc_id
  protect_subnet_ids            = module.vpc[each.value.vpc_name].protect_subnet_ids
  name                          = each.key
  engine_version                = each.value.engine_version
  data_storage                  = each.value.data_storage
  ecpu_per_second               = each.value.ecpu_per_second

  security_group_name           = each.value.security_group_name
  ingress_ports                 = each.value.ingress_ports
  egress_ports                  = each.value.egress_ports
}