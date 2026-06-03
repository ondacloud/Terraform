locals {
  parameter = "demo"
}

locals {
  kmss = {
    "${local.parameter}/kms/cw" = {
      tags = {Name = "${local.parameter}/kms/cw"}
      
      alias_name              = "alias/${local.parameter}/kms/cw"
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
        {
          effect = "Allow"
          principals = {type = "Service", identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]}
          actions = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"]
          resources = ["*"]
          conditions = []
        }
      ]
    },
  }
}

locals {
  cloudwatch_logs = {
    "/${local.parameter}/app/log" = {
      tags = {Name = "/${local.parameter}/app/log"}

      enable_kms = true
      kms_key_name = "${local.parameter}/kms/cw"

      retention_in_days = 7
    },
  }
}