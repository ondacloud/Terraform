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
  depends_on = [ module.vpc ]
  
  source = "./modules/nlb"

  for_each = local.nlbs

  vpc_id                           = module.vpc[each.value.vpc_name].vpc_id
  subnet_ids                       = each.value.internal ? module.vpc[each.value.vpc_name].private_subnet_ids : module.vpc[each.value.vpc_name].public_subnet_ids

  name                             = each.key
  nlb_tags                         = each.value.nlb_tags
  internal                         = each.value.internal
  enable_cross_zone_load_balancing = each.value.enable_cross_zone_load_balancing
  port                             = each.value.port
  protocol                         = each.value.protocol

  default_action              = each.value.default_action
  enable_listener_rules       = each.value.enable_listener_rules
  listener_rules              = each.value.listener_rules
  
  target_groups               = each.value.target_groups
  enable_attach_target        = each.value.enable_attach_target
  targets                     = each.value.targets
  # target_info                 = each.value.enable_attach_target ? {for t in each.value.targets : t.target_name => module.ec2[t.target_name].ec2_instance_id} : {}
}