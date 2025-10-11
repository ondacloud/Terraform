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

module "nlb" {
  source = "./modules/nlb"

  for_each = local.nlbs

  vpc_id                           = module.vpc[each.value.vpc_name].vpc_id
  subnet_ids                       = each.value.internal ? module.vpc[each.value.vpc_name].private_subnet_ids : module.vpc[each.value.vpc_name].public_subnet_ids

  name                             = each.key
  internal                         = each.value.internal
  enable_cross_zone_load_balancing = each.value.enable_cross_zone_load_balancing
  port                             = each.value.port
  protocol                         = each.value.protocol
  target_groups                    = each.value.target_groups
  listener_target_groups           = each.value.listener_target_groups

  enable_target                    = each.value.enable_target
  targets                          = each.value.targets
  # ec2_info                         = {for t in each.value.targets : t.target_name => module.ec2[t.target_name].ec2_instance_id}
}