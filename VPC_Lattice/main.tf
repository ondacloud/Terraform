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

  default_action              = each.value.default_action
  enable_listener_rules       = each.value.enable_listener_rules
  listener_rules              = each.value.listener_rules

  target_groups               = each.value.target_groups

  security_group_name         = each.value.security_group_name
  security_group_tags         = each.value.security_group_tags
  ingress_ports               = each.value.ingress_ports
  egress_ports                = each.value.egress_ports

  enable_attach_target        = each.value.enable_attach_target
  targets                     = each.value.targets
  target_info                 = each.value.enable_attach_target ? {for t in each.value.targets : t.target_name => module.ec2[t.target_name].ec2_instance_id} : {}
}

module "vpc_lattice" {
  depends_on = [ module.vpc, module.alb ]

  source = "./modules/vpc_lattice"

  for_each = local.vpc_lattices

  vpc_names                      = each.value.vpc_names
  vpc_ids                        = { for vpc_name in each.value.vpc_names : vpc_name => module.vpc[vpc_name].vpc_id }
  alb_arn                        = module.alb[each.value.alb_name].alb_arn
  service_network_name           = each.value.service_network_name
  service_network_auth_type      = each.value.service_network_auth_type
  service_network_tags           = each.value.service_network_tags
  service_network_vpc_tags       = each.value.service_network_vpc_tags

  service_name                   = each.value.service_name
  service_auth_type              = each.value.service_auth_type
  service_tags                   = each.value.service_tags
  service_association_tags       = each.value.service_association_tags

  security_group_names           = each.value.security_group_names
  security_group_tags            = each.value.security_group_tags
  ingress_ports                  = each.value.ingress_ports
  egress_ports                   = each.value.egress_ports

  target_groups                  = each.value.target_groups
  listener_name                  = each.value.listener_name
  listener_protocol              = each.value.listener_protocol
  listener_port                  = each.value.listener_port
  listener_rules                 = each.value.listener_rules
  default_forward_target_groups  = each.value.default_forward_target_groups

  enable_attach_target           = each.value.enable_attach_target
  targets                        = each.value.targets
  target_info                    = each.value.enable_attach_target ? [for t in each.value.targets : module.alb[t.target_name].alb_arn] : []
}