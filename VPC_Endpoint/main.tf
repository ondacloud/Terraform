module "vpc" {
  source = "./modules/vpc"

  for_each = local.vpcs

  az_override      = local.az_override
  azs              = local.azs
  enable_igw       = each.value.enable_igw
  enable_natgw     = each.value.enable_natgw

  default_rtb_tags = each.value.default_rtb_tags
  default_sg_tags  = each.value.default_sg_tags
  vpc_name         = each.key
  vpc_cidr         = each.value.vpc_cidr
  vpc_tags         = each.value.vpc_tags
  types            = each.value.types
}

module "security_group" {
  depends_on = [ module.vpc ]
  source = "./modules/security_group"

  for_each = local.security_groups

  vpc_id                = module.vpc[each.value.vpc_name].vpc_id

  security_group_name   = each.value.security_group_name
  security_group_tags   = each.value.security_group_tags
  ingress_ports         = each.value.ingress_ports
  egress_ports          = each.value.egress_ports
}

module "endpoint" {
  depends_on = [ module.vpc, module.security_group ]

  source = "./modules/endpoint"

  for_each = local.endpoints

  vpc_id                = module.vpc[each.value.vpc_name].vpc_id
  subnet_ids            = each.value.endpoint_type == "Interface" ? module.vpc[each.value.vpc_name].subnet_ids_by_type[each.value.type] : null
  route_table_ids       = each.value.endpoint_type == "Gateway" ? module.vpc[each.value.vpc_name].route_table_ids_by_type[each.value.type] : null

  service_name          = "com.amazonaws.${var.region}.${each.value.service_name}"
  endpoint_type         = each.value.endpoint_type
  enable_private_dns    = each.value.enable_private_dns
  security_group_id     = module.security_group[each.value.security_group_name].security_group_id
  tags                  = each.value.tags
}