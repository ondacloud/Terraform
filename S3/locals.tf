locals {
  parameter = "demo"
}

locals {
  kmss = {
    "${local.parameter}/kms/s3" = {
      tags = {Name = "${local.parameter}/kms/s3"}
      
      alias_name              = "alias/${local.parameter}/kms/s3"
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
        # {
        #   effect = "Allow"
        #   principals = {type = "Service", identifiers = ["cloudfront.amazonaws.com"]}
        #   actions = ["kms:Decrypt", "kms:GenerateDataKey*"]
        #   resources = ["*"]
        #   conditions = []
        # }
      ]
    },
  }
}

locals {
  s3s = {
    "${local.parameter}-bucket-${data.aws_caller_identity.current.account_id}" = {
      tags = {Name = "${local.parameter}-bucket-${data.aws_caller_identity.current.account_id}"}
      
      enable_objects    = true
      objects = [
        {key = "static/index.html", source = "s3/index.html"},
      ]

      enable_bucket_kms = true
      enable_object_kms = true
      server_side_encryption = "aws:kms" # aws:kms:dsse
      kms_key_name = "${local.parameter}/kms/s3"
    },
  }
}