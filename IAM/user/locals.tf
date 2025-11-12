locals {
  iams = {
    "iam-user" = {
      user_tags = {Name = "iam-user"}

      statements = [
        {
          effect    = "Allow"
          actions   = ["iam:*"]
          resources = ["*"]
          conditions = []
        }
      ]

      enable_inline_policy  = false
      inline_policy_name    = "iam-inline-policy"

      enable_custom_policy  = false
      policy_name           = "iam-policy"
      policy_tags = {Name = "iam-policy"}

      enable_managed_policy  = false
      managed_policy_arns    = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
  }
}