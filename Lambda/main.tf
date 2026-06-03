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

module "lambda" {
  depends_on = [ module.vpc ]

  source = "./modules/lambda"

  for_each = local.lambdas

  name                = each.key
  tags                = each.value.tags
  handler             = each.value.handler
  timeout             = each.value.timeout
  runtime             = each.value.runtime
  source_file_path    = each.value.source_file_path
  output_file_path    = each.value.output_file_path
  publish             = each.value.publish
  
  enable_lambda_edge  = each.value.enable_lambda_edge
  enable_upload_zip   = each.value.enable_upload_zip
  
  iam_role_name       = each.value.iam_role_name
  iam_role_tags       = each.value.iam_role_tags
  iam_policies        = each.value.iam_policies

  enable_vpc_config   = each.value.enable_vpc_config
  vpc_id              = module.vpc[each.value.vpc_name].vpc_id
  subnet_ids          = each.value.internal ? module.vpc[each.value.vpc_name].private_subnet_ids : module.vpc[each.value.vpc_name].public_subnet_ids
  security_group_name = each.value.security_group_name
  security_group_tags = each.value.security_group_tags
  ingress_ports       = each.value.ingress_ports
  egress_ports        = each.value.egress_ports
}