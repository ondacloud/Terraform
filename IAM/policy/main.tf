module "iam" {
  source = "./modules/iam"

  for_each = local.iams

  policy_name   = each.key
  statements    = each.value.statements
  policy_tags   = each.value.policy_tags
}