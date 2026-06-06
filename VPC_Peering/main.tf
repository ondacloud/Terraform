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

module "vpc_peering" {
  source = "./modules/vpc_peering"

  for_each = local.vpc_peerings

  tags                      = each.value.tags
  auto_accept               = each.value.auto_accept

  requestor = {
    vpc_id          = module.vpc[each.value.requestor.vpc_name].vpc_id
    vpc_cidr        = module.vpc[each.value.requestor.vpc_name].vpc_cidr
    route_table_ids = [for rt_name in each.value.requestor.route_table_names : module.vpc[each.value.requestor.vpc_name].route_table_ids[rt_name]]
    allow_remote_vpc_dns_resolution = each.value.requestor.allow_remote_vpc_dns_resolution
  }

  accepter = {
    vpc_id          = module.vpc[each.value.accepter.vpc_name].vpc_id
    vpc_cidr        = module.vpc[each.value.accepter.vpc_name].vpc_cidr
    route_table_ids = [for rt_name in each.value.accepter.route_table_names : module.vpc[each.value.accepter.vpc_name].route_table_ids[rt_name]]
    allow_remote_vpc_dns_resolution = each.value.accepter.allow_remote_vpc_dns_resolution
  }
}