module "vpc" {
  source = "./modules/vpc"

  for_each = local.vpcs
  
  parameter    = local.parameter
  az_override  = local.az_override
  azs          = local.azs
  enable_igw   = each.value.enable_igw
  enable_natgw = each.value.enable_natgw

  default_rtb_name = each.value.default_rtb_name
  vpc_name     = each.key
  vpc_cidr     = each.value.vpc_cidr
  types        = each.value.types
}