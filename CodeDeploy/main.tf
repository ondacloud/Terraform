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
  # target_info                 = each.value.enable_attach_target ? {for t in each.value.targets : t.target_name => module.ec2[t.target_name].ec2_instance_id} : {}
}

module "codedeploy" {
  source = "./modules/codedeploy"

  for_each = local.codedeploys

  app_name                            = each.key
  app_tags                            = each.value.app_tags

  compute_platform                    = each.value.compute_platform
  deployment_config_name              = each.value.deployment_config_name
  
  deployment_group_name               = each.value.deployment_group_name
  deployment_group_tags               = each.value.deployment_group_tags
  
  outpdated_instances_strategy        = each.value.outpdated_instances_strategy
  auto_rollback_configuration_enabled = each.value.auto_rollback_configuration_enabled
  auto_rollback_configuration_events  = each.value.auto_rollback_configuration_events

  deployment_style                    = each.value.deployment_style
  ec2_tag_set                         = each.value.compute_platform == "Server" ? lookup(each.value, "ec2_tag_set", []) : []

  minimum_healthy_hosts               = lookup(each.value, "minimum_healthy_hosts", null)
  traffic_routing_config              = lookup(each.value, "traffic_routing_config", null)
  blue_green_deployment_config        = each.value.compute_platform == "ECS" ? lookup(each.value, "blue_green_deployment_config", null) : null
  ecs_service                         = each.value.compute_platform == "ECS" ? lookup(each.value, "ecs_service", []) : []
  load_balancer_info                  = lookup(each.value, "load_balancer_info", null)

  enable_iam_role                     = each.value.enable_iam_role
  iam_role_name                       = each.value.iam_role_name
  iam_role_tags                       = each.value.iam_role_tags
  statements                          = each.value.statements
  iam_policy_name                     = each.value.iam_policy_name
  iam_policy_tags                     = each.value.iam_policy_tags
}