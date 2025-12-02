locals {
  container_taskdefinition = {
    for family, c in var.containers : family => concat([
      {
        name      = c.name
        image     = c.enable_ecr ? format("%s:%s", var.app_ecr_url, c.app_image_tag) : c.app_image
        essential = c.essential
        cpu       = c.cpu
        memory    = c.memory

        portMappings = c.port_mappings != null ? [
          {
            containerPort = c.port_mappings.container_port
            hostPort      = c.port_mappings.host_port
            protocol      = c.port_mappings.protocol
          }
        ] : []

        healthCheck = c.health_check

        environment = c.enable_environment ? [for k, v in c.environment : { name = k, value = v }] : []

        secrets = c.enable_secrets_manager ? [
          for s in c.secrets : {
            name      = s.name
            valueFrom = "${var.secrets_manager_arn[c.secrets_manager_name]}:${s.valueFrom}::"
          }
        ] : []

        logConfiguration = c.enable_awslogs ? {
          logDriver = "awslogs"
          options = {
            awslogs-group         = c.cloudwatch_log_group_name
            awslogs-stream-prefix = "awslogs"
            awslogs-region        = data.aws_region.caller.id
            awslogs-create-group  = "true"
          }
        } : c.enable_fluentbit ? {
          logDriver = "awsfirelens"
          options = c.firelens_type == "cloudwatch_logs" ? {
            Name              = "cloudwatch_logs"
            log_group_name    = c.cloudwatch_log_group_name
            log_stream_prefix = c.cloudwatch_log_stream_prefix
            region            = data.aws_region.caller.id
            auto_create_group = "true"
          } : c.firelens_type == "opensearch" ? {
            Name               = "es"
            AWS_Auth           = "On"
            Host               = var.opensearch_host
            Index              = c.opensearch_index
            Port               = 443
            Suppress_Type_Name = "On"
            tls                = "On"
            AWS_Region         = data.aws_region.caller.id
          } : null
        } : null
      }
    ],
    (c.enable_fluentbit) ? [
      {
        name      = "log_router"
        image     = var.log_image_uri != null ? var.log_image_uri : (c.enable_fluentbit && lookup(var.log_ecr_url, family, null) != null ? lookup(var.log_ecr_url, family) : "public.ecr.aws/aws-observability/aws-for-fluent-bit:latest")
        essential = false
        firelensConfiguration = {
          type = "fluentbit"
          options = c.enable_fluentbit_file_type == "file" ? {
            config-file-type        = "file"
            config-file-value       = "/extra.conf"
            enable-ecs-log-metadata = "true"
          } : c.enable_fluentbit_file_type == "s3" ? {
            config-file-type        = "s3"
            config-file-value       = "arn:aws:s3:::${c.s3_bucket_path}/extra.conf"
            enable-ecs-log-metadata = "true"
          } : null
        }
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = c.cloudwatch_log_group_name
            awslogs-stream-prefix = "awslogs"
            awslogs-region        = data.aws_region.caller.id
            awslogs-create-group  = "true"
          }
        }
      }
    ] : [])
  }

  json_map = { for family, defs in local.container_taskdefinition : family => jsonencode(defs) }
}
