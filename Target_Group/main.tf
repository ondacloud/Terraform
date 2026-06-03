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

module "target_group" {
  depends_on = [ module.vpc, module.lambda ]
  
  source = "./modules/target_group"

  for_each = local.target_groups

  vpc_id                      = module.vpc[each.value.vpc_name].vpc_id

  target_groups               = each.value.target_groups


  enable_attach_target        = each.value.enable_attach_target
  targets                     = each.value.targets
  target_info                 = each.value.enable_attach_target ? {for t in each.value.targets : t.target_name => module.lambda[t.target_name].lambda_arn} : {}
}
