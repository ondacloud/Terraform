locals {
  iams = {
    "ec2-role" = {
      service_name = "ec2"

      role_tags = {
        Name = "ec2-role"
      }

      enable_custom_policy = true
      policy_name          = "ec2-policy"
      policy_tags = {
        Name = "ec2-policy"
      }

      statements = [
        {
          effect    = "Allow"
          actions   = ["ec2:*"]
          resources = ["*"]
          conditions = []
        }
      ]

      enable_managed_policy = true
      managed_policy_arns   = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
  }
}