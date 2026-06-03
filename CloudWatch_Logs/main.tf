module "kms" {
  source = "./modules/kms"

  for_each = local.kmss

  name                    = each.key
  tags                    = each.value.tags
  alias_name              = each.value.alias_name
  key_usage               = each.value.key_usage
  deletion_window_in_days = each.value.deletion_window_in_days
  statements              = each.value.statements
}

module "cloudwatch_logs" {
  depends_on = [ module.kms ]

  source = "./modules/cloudwatch_logs"

  for_each = local.cloudwatch_logs

  name       = each.key
  tags       = each.value.tags
  enable_kms = each.value.enable_kms
  kms_key_id = each.value.enable_kms ? module.kms[each.value.kms_key_name].kms_arn : null
  # kms_key_id = null
}