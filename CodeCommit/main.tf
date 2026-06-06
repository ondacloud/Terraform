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

module "codecommit" {
  depends_on = [module.kms]

  source = "./modules/codecommit"

  for_each = local.codecommits

  name       = each.key
  tags       = each.value.tags
  kms_key_id = each.value.enable_kms ? module.kms[each.value.kms_key_name].kms_arn : null
  # kms_key_id = null
}