locals {
  parameter = "demo"
}

locals {
  kmss = {
    "${local.parameter}/ecr/kms" = {
      tags = {
        Name = "${local.parameter}-ecr-kms"
      }
      
      alias_name              = "alias/${local.parameter}/ecr/kms"
      key_usage               = "ENCRYPT_DECRYPT"
      deletion_window_in_days = 7
    }
  }
}

locals {
  ecrs = {
    "${local.parameter}-ecr" = {
      tags = {
        Name = "${local.parameter}-ecr"
      }

      image_tag_mutability              = "IMMUTABLE" # IMMUTABLE or MUTABLE
      force_delete                      = true
      scan_images_on_push               = true

      enable_kms                        = true
      kms_key_name                      = "${local.parameter}/ecr/kms"
      encryption_type                   = "KMS"

      # Use IMMUTABLE_WITH_EXCLUSION or MUTABLE_WITH_EXCLUSION for image_tag_mutability when using enable_image_tag_exclusion_filter
      enable_image_tag_exclusion_filter = false
      image_tag_exclusion_filter = [
        {filter = "latest", filter_type = "WILDCARD"},
      ]
    }
  }
}