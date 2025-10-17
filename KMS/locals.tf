locals {
  parameter = "demo"
}

locals {
  kmss = {
    "${local.parameter}/kms" = {
      tags = {
        Name = "${local.parameter}/kms"
      }
      
      alias_name              = "alias/${local.parameter}/kms"
      key_usage               = "ENCRYPT_DECRYPT"
      deletion_window_in_days = 7
    }
  }
}