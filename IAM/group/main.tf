module "iam" {
  source = "./modules/iam"

  for_each = local.iams

  group_name            = each.key
  path                  = each.value.path
  enable_group          = each.value.enable_group
  user_name             = each.value.user_name
  user_tags             = each.value.user_tags
  statements            = each.value.statements
  enable_inline_policy  = each.value.enable_inline_policy
  inline_policy_name    = each.value.inline_policy_name
  enable_custom_policy  = each.value.enable_custom_policy
  policy_name           = each.value.policy_name
  policy_tags           = each.value.policy_tags
  enable_managed_policy = each.value.enable_managed_policy
  managed_policy_arns   = each.value.managed_policy_arns
}