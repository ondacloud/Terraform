module "waf" {
  source = "./modules/waf"

  providers = {aws = aws.us_east_1}

  for_each = local.wafs

  name                 = each.key
  tags                 = each.value.tags
  metric_name          = each.value.metric_name
  enable_cloudfront    = each.value.enable_cloudfront
  alb_arn              = null
  enable_managed       = each.value.enable_managed
  managed_rules        = each.value.managed_rules
  enable_custom        = each.value.enable_custom
  custom_rules         = each.value.custom_rules
  enable_logging       = each.value.enable_logging
  # log_destination_arns = each.value.enable_logging ? [module.cloudwatch_logs[each.value.cloudwatch_logs_group_name].cloudwatch_logs_arn] : []
  log_destination_arns = null
}