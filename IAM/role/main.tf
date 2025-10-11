module "iam" {
  source = "./modules/iam"

  for_each = local.iams

  role_name             = each.key
  role_tags             = each.value.role_tags
  service_name          = each.value.service_name
  enable_custom_policy  = each.value.enable_custom_policy
  policy_name           = each.value.policy_name
  policy_tags           = each.value.policy_tags
  statements            = each.value.statements
  enable_managed_policy = each.value.enable_managed_policy
  managed_policy_arns   = each.value.managed_policy_arns
}