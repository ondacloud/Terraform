locals {
  parameter = "demo"
}

locals {
  kmss = {
    "${local.parameter}/kms/sqs" = {
      tags = {Name = "${local.parameter}/kms/sqs"}
      
      alias_name              = "alias/${local.parameter}/kms/sqs"
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
  sqss = {
    "${local.parameter}-sqs" = {
      tags = {Name = "${local.parameter}-sqs"}
      
      delay_seconds = 0
      max_message_size = 262144
      message_retention_seconds = 345600
      receive_wait_time_seconds = 0
      visibility_timeout_seconds = 30

      fifo_queue = false
      content_based_deduplication = false
      fifo_throughput_limit = "perMessageGroupId" # perQueue
      deduplication_scope = "queue" # messageGroup

      enable_kms = true
      kms_name = "${local.parameter}/kms/sqs"
      kms_data_key_reuse_period_seconds = 300
      sqs_managed_sse_enabled = false
    }
  }
}