resource "aws_security_group" "this" {
  count = var.enable_vpc_config ? 1 : 0
  name   = var.security_group_name
  vpc_id = var.vpc_config.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = [ingress.value.cidr_block]
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      protocol    = egress.value.protocol
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      cidr_blocks = [egress.value.cidr_block]
    }
  }

  tags = var.security_group_tags
}

resource "aws_iam_role" "this" {
  count = var.enable_iam_role ? 1 : 0

  name               = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.statements
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
      
      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_policy" "this" {
  count  = var.enable_iam_role ? 1 : 0

  name   = var.policy_name
  policy = data.aws_iam_policy_document.this.json
  tags   = var.policy_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.enable_iam_role ? 1 : 0
  
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_codebuild_source_credential" "github" {
  count = var.source_type == "GITHUB" ? 1 : 0

  server_type = "GITHUB"
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  token       = var.github_access_token
}

resource "aws_s3_bucket" "this" {
  count = var.enable_cache ? 1 : 0
  bucket = var.cache.location

  tags = {
    Name = var.cache.location
  }
}

resource "aws_codebuild_project" "this" {
  name          = var.name
  service_role  = var.enable_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn

  artifacts {
    type     = var.artifact_type
  }
  
  dynamic "cache" {
    for_each = var.enable_cache ? [var.cache] : [] 
    content {
      type     = cache.value.type
      location = cache.value.type == "S3" ? aws_s3_bucket.this[0].bucket : null
      modes    = lookup(cache.value, "modes", [])
    }
  }

  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    image_pull_credentials_type = var.build_image_pull_credentials_type
    type                        = var.build_type
    privileged_mode             = var.enable_file_system ? true : var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables 
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.enable_vpc_config ? [var.vpc_config] : [] 
    content {
      vpc_id             = vpc_config.value.vpc_id
      subnets            = vpc_config.value.subnets
      security_group_ids = [aws_security_group.this[0].id]
    }
  }

  dynamic "logs_config" {
    for_each = var.enable_logs ? [var.logs_config] : [] 
    content {
      dynamic "cloudwatch_logs" {
        for_each = lookup(logs_config.value, "cloudwatch_logs", null) != null ? [logs_config.value.cloudwatch_logs] : []
        content {
          status      = cloudwatch_logs.value.status
          group_name  = cloudwatch_logs.value.group_name
          stream_name = cloudwatch_logs.value.stream_name
        }
      }

      dynamic "s3_logs" {
        for_each = lookup(logs_config.value, "s3_logs", null) != null ? [logs_config.value.s3_logs] : []
        content {
          status            = s3_logs.value.status
          location          = s3_logs.value.location
          encryption_disabled = s3_logs.value.encryption_disabled
        }
      }
    }
  }

  dynamic "file_system_locations" {
    for_each = var.enable_file_system ? var.file_system_locations : []
    content {
      type          = "EFS"
      identifier    = file_system_locations.value.identifier
      location      = file_system_locations.value.location
      mount_point   = file_system_locations.value.mount_point
    }
  }

  source {
    type                = var.source_type
    buildspec           = var.buildspec
    location            = var.source_location
    report_build_status = var.report_build_status
  }

  tags = var.tags
}