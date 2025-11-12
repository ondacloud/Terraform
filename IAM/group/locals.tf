locals {
  iams = {
    "iam-group" = {
      path       = "/"
      enable_group = true

      user_name = "iam-group"
      user_tags = {Name = "iam-user"}

      statements = [
        {
          effect    = "Allow"
          actions   = ["iam:*"]
          resources = ["*"]
          conditions = []
        }
      ]

      enable_inline_policy  = true
      inline_policy_name    = "iam-inline-policy"

      enable_custom_policy  = true
      policy_name           = "iam-policy"
      policy_tags = {Name = "iam-policy"}

      enable_managed_policy  = true
      managed_policy_arns    = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
  }
}