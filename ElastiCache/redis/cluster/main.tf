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

  engine                        = each.value.engine
  engine_version                = each.value.engine_version
  node_type                     = each.value.node_type
  port                          = each.value.port
  num_cache_nodes               = each.value.num_cache_nodes
  az_mode                       = each.value.az_mode
  apply_immediately             = each.value.apply_immediately

  subnet_group_name             = each.value.subnet_group_name

  parameter_group_name          = each.value.parameter_group_name
  parameter_group_family        = each.value.parameter_group_family

  security_group_name           = each.value.security_group_name
  ingress_ports                 = each.value.ingress_ports
  egress_ports                  = each.value.egress_ports
}