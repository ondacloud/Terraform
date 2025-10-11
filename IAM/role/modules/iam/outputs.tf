output "policy_arn" {
  value = var.enable_custom_policy ? aws_iam_policy.this[0].arn : null
}

output "policy_name" {
  value = var.enable_custom_policy ? aws_iam_policy.this[0].name : null
}