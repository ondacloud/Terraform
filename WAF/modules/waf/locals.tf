locals {
  managed_rules = var.enable_managed ? [for r in var.managed_rules : r if r.enabled] : []
  custom_rules  = var.enable_custom ? [for r in var.custom_rules : r if r.enabled] : []
}