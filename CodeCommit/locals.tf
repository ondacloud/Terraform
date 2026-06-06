locals {
  parameter = "demo"
}

locals {
  kmss = {
    "${local.parameter}/kms/commit" = {
      tags = {Name = "${local.parameter}/kms/commit"}
      
      alias_name              = "alias/${local.parameter}/kms/commit"
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

locals {
  codecommits = {
    "${local.parameter}-commit" = {
      tags = {Name = "${local.parameter}-commit"}

      enable_kms = true
      kms_key_name = "${local.parameter}/kms/commit"
    }
  }
}