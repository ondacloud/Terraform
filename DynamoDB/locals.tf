locals {
  parameter = "demo"
}

locals {
  kmss = {
    "${local.parameter}/kms/dynamodb" = {
      tags = {Name = "${local.parameter}/kms/dynamodb"}
      
      alias_name              = "alias/${local.parameter}/kms/dynamodb"
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
  dynamodbs = {
    "${local.parameter}-table" = {
      tags = {Name = "${local.parameter}-table"}

      billing_mode   = "PAY_PER_REQUEST" # PROVISIONED
      read_capacity  = 20
      write_capacity = 20

      enable_kms    = true
      kms_key_name  = "${local.parameter}/kms/dynamodb"

      hash_key = "name"
      range_key = null

      attributes = [
        {name = "name", type = "S"},
      ]

      enable_ttl = false
      ttl_attribute_name = "name"

      enable_point_in_time_recovery = false
      recovery_period_in_days = 7

      enable_local_secondary_indexes = false
      local_secondary_indexes = [
        {
          name = "name-index"
          range_key = null
          projection_type = "ALL" # ALL, KEYS_ONLY, INCLUDE
          non_key_attributes = null
        },
      ]

      enable_global_secondary_indexes = false
      global_secondary_indexes = [
        {
          name = "name-index"
          hash_key = "name"
          range_key = null
          projection_type = "ALL" # ALL, KEYS_ONLY, INCLUDE
          non_key_attributes = null
          read_capacity = 20
          write_capacity = 20
        },
      ]

      enable_replicas = false
      replicas = [
        {
          enable_replica_kms = false
          enable_replica_point_in_time_recovery = false
          region_name = "us-east-1"
          kms_key_name = "${local.parameter}/kms/dynamodb"
          propagate_tags = null
          point_in_time_recovery = null
          consistency_mode = null
        },
      ]

      enable_items = false
      items = [
        {name = "demo", age = 22, country = "korea"},
      ]
    }
  }
}