resource "aws_iam_user" "this" {
  name = var.user_name

  tags = var.user_tags
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.statements
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
      
      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_policy" "this" {
  count  = var.enable_custom_policy ? 1 : 0

  name   = var.policy_name
  policy = data.aws_iam_policy_document.this.json
  tags   = var.policy_tags
}

resource "aws_iam_user_policy" "inline" {
  count  = var.enable_inline_policy ? 1 : 0

  name   = var.inline_policy_name
  user   = aws_iam_user.this.name
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_user_policy_attachment" "custom" {
  count      = var.enable_custom_policy ? 1 : 0

  user       = aws_iam_user.this.name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_user_policy_attachment" "managed" {
  for_each = var.enable_managed_policy ? { for p in var.managed_policy_arns : p => p } : {}

  user       = aws_iam_user.this.name
  policy_arn = each.value
}
