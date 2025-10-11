module "vpc" {
  source = "./modules/vpc"

  for_each = local.vpcs
  
  az_override  = local.az_override
  azs          = local.azs
  enable_igw   = each.value.enable_igw
  enable_natgw = each.value.enable_natgw

  default_rtb_name = each.value.default_rtb_name
  vpc_name     = each.key
  vpc_cidr     = each.value.vpc_cidr
  types        = each.value.types
}

module "ec2" {
  depends_on = [ module.vpc ]

  source = "./modules/ec2"

  for_each = local.ec2s

  vpc_id                = module.vpc[each.value.vpc_name].vpc_id
  subnet_id             = module.vpc[each.value.vpc_name].subnet_ids[each.value.subnet_name]
  name                  = each.key

  security_group_name   = each.value.security_group_name
  instance_type         = each.value.instance_type
  userdata              = each.value.userdata
  instance_tags         = each.value.instance_tags

  enable_public_ip      = each.value.enable_public_ip
  enable_eip            = each.value.enable_eip
  eip_tags              = each.value.eip_tags

  ingress_ports         = each.value.ingress_ports
  egress_ports          = each.value.egress_ports

  enable_create_keypair = each.value.enable_create_keypair
  keypair_name          = each.value.keypair_name
  keypair_file_path     = each.value.keypair_file_path

  enable_create_iam_role = each.value.enable_create_iam_role
  iam_role_name         = each.value.iam_role_name
  instance_profile_name = each.value.instance_profile_name
  iam_policies          = each.value.iam_policies
}
