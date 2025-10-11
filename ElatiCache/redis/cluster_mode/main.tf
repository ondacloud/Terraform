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
  source = "./modules/elaticache"

  for_each = local.elaticaches

  vpc_id                        = module.vpc[each.value.vpc_name].vpc_id
  protect_subnet_ids            = module.vpc[each.value.vpc_name].protect_subnet_ids
  name                          = each.key

  node_type                     = each.value.node_type
  engine                        = each.value.engine
  engine_version                = each.value.engine_version
  port                          = each.value.port
  num_node_groups               = each.value.num_node_groups
  replicas_per_node_group       = each.value.replicas_per_node_group
  automatic_failover_enabled    = each.value.automatic_failover_enabled
  multi_az_enabled              = each.value.multi_az_enabled
  apply_immediately             = each.value.apply_immediately
  at_rest_encryption_enabled    = each.value.at_rest_encryption_enabled
  transit_encryption_enabled    = each.value.transit_encryption_enabled
  transit_encryption_mode       = each.value.transit_encryption_mode

  subnet_group_name             = each.value.subnet_group_name

  parameter_group_name          = each.value.parameter_group_name
  parameter_group_family        = each.value.parameter_group_family
  parameters                    = each.value.parameters

  security_group_name           = each.value.security_group_name
  ingress_ports                 = each.value.ingress_ports
  egress_ports                  = each.value.egress_ports
}