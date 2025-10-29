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

module "alb" {
  depends_on = [ module.vpc ]
  
  source = "./modules/alb"

  for_each = local.albs

  vpc_id                      = module.vpc[each.value.vpc_name].vpc_id
  subnet_ids                  = each.value.internal ? module.vpc[each.value.vpc_name].private_subnet_ids : module.vpc[each.value.vpc_name].public_subnet_ids

  name                        = each.key
  alb_tags                    = each.value.alb_tags
  internal                    = each.value.internal
  port                        = each.value.port
  protocol                    = each.value.protocol
  target_groups               = each.value.target_groups
  listener_target_groups      = each.value.listener_target_groups

  security_group_name         = each.value.security_group_name
  security_group_tags         = each.value.security_group_tags
  ingress_ports               = each.value.ingress_ports
  egress_ports                = each.value.egress_ports

  enable_attach_target        = each.value.enable_attach_target
  targets                     = each.value.targets
  # ec2_info                    = each.value.enable_attach_target ? {for t in each.value.targets : t.target_name => module.ec2[t.target_name].ec2_instance_id} : {}
}