module "api_gateway" {
  depends_on = [module.lambda]

  source = "./modules/api_gateway"

  for_each = local.api_gateways

  name                        = each.key
  tags                        = each.value.tags
  stage_name                  = each.value.stage_name
  enable_api_key              = each.value.enable_api_key
  api_key_name                = each.value.api_key_name
  api_key_tags                = each.value.api_key_tags
  usage_plan_name             = each.value.usage_plan_name
  usage_plan_tags             = each.value.usage_plan_tags
  enable_throttle_settings    = each.value.enable_throttle_settings
  rate_limit                  = each.value.rate_limit
  burst_limit                 = each.value.burst_limit
  api_maps                    = each.value.api_maps

  enable_lambda     = each.value.enable_lambda
  lambda_name       = module.lambda[each.value.lambda_name].lambda_name
  lambda_invoke_arn = module.lambda[each.value.lambda_name].lambda_invoke_arn
  service_arn       = null

  iam_role_name = each.value.iam_role_name
  iam_role_tags = each.value.iam_role_tags
  iam_policies  = each.value.iam_policies
}