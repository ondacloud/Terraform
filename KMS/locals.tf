locals {
  parameter = "demo"
}

locals {
  kmss = {
    "${local.parameter}/kms" = {
      tags = {Name = "${local.parameter}/kms"}
      
      alias_name              = "alias/${local.parameter}/kms"
      key_usage               = "ENCRYPT_DECRYPT"
      deletion_window_in_days = 7
      statements = [
        {
          effect = "Allow"
          principals = {type = "AWS", identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]}
          actions   = ["kms:*"]
          resources = ["*"]
          conditions = []
        },
      ]
    },
  }
}