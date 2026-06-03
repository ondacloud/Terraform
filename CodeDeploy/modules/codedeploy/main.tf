resource "aws_iam_role" "this" {
  count = var.enable_iam_role ? 1 : 0

  name = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codedeploy.amazonaws.com" }
    }]
  })
  tags = var.iam_role_tags
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

  name   = var.iam_policy_name
  policy = data.aws_iam_policy_document.this.json
  tags   = var.iam_policy_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.enable_iam_role ? 1 : 0
  
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_codedeploy_app" "this" {
  name             = var.app_name
  compute_platform = var.compute_platform

  tags = var.app_tags
}

resource "aws_codedeploy_deployment_config" "this" {
  deployment_config_name = var.deployment_config_name
  compute_platform       = var.compute_platform

  dynamic "minimum_healthy_hosts" {
    for_each = var.minimum_healthy_hosts == null ? [] : [var.minimum_healthy_hosts]
    content {
      type  = minimum_healthy_hosts.value.type
      value = minimum_healthy_hosts.value.value
    }
  }

  dynamic "traffic_routing_config" {
    for_each = var.traffic_routing_config == null ? [] : [var.traffic_routing_config]

    content {
      type = traffic_routing_config.value.type

      dynamic "time_based_linear" {
        for_each = var.traffic_routing_config != null && lookup(var.traffic_routing_config, "type", null) == "TimeBasedLinear" ? [var.traffic_routing_config] : []

        content {
          interval   = traffic_routing_config.value.interval
          percentage = traffic_routing_config.value.percentage
        }
      }

      dynamic "time_based_canary" {
        for_each = var.traffic_routing_config != null && lookup(var.traffic_routing_config, "type", null) == "TimeBasedCanary" ? [var.traffic_routing_config] : []

        content {
          interval   = traffic_routing_config.value.interval
          percentage = traffic_routing_config.value.percentage
        }
      }
    }
  }
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = aws_codedeploy_deployment_config.this.deployment_config_name
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = aws_iam_role.this[0].arn
  outdated_instances_strategy = var.outpdated_instances_strategy

  dynamic "auto_rollback_configuration" {
    for_each = var.auto_rollback_configuration_enabled ? [1] : [0]

    content {
      enabled = var.auto_rollback_configuration_enabled
      events  = [var.auto_rollback_configuration_events]
    }
  }


  dynamic "blue_green_deployment_config" {
    for_each = var.blue_green_deployment_config == null ? [] : [var.blue_green_deployment_config]
    content {
      dynamic "deployment_ready_option" {
        for_each = lookup(blue_green_deployment_config.value, "deployment_ready_option", null) == null ? [] : [lookup(blue_green_deployment_config.value, "deployment_ready_option", {})]

        content {
          action_on_timeout    = lookup(deployment_ready_option.value, "action_on_timeout", null)
          wait_time_in_minutes = lookup(deployment_ready_option.value, "wait_time_in_minutes", null)
        }
      }

      dynamic "green_fleet_provisioning_option" {
        for_each = lookup(blue_green_deployment_config.value, "green_fleet_provisioning_option", null) == null ? [] : [lookup(blue_green_deployment_config.value, "green_fleet_provisioning_option", {})]

        content {
          action = lookup(green_fleet_provisioning_option.value, "action", null)
        }
      }

      dynamic "terminate_blue_instances_on_deployment_success" {
        for_each = lookup(blue_green_deployment_config.value, "terminate_blue_instances_on_deployment_success", null) == null ? [] : [lookup(blue_green_deployment_config.value, "terminate_blue_instances_on_deployment_success", {})]

        content {
          action                           = lookup(terminate_blue_instances_on_deployment_success.value, "action", null)
          termination_wait_time_in_minutes = lookup(terminate_blue_instances_on_deployment_success.value, "termination_wait_time_in_minutes", null)
        }
      }
    }
  }

  dynamic "deployment_style" {
    for_each = var.deployment_style == null ? [] : [var.deployment_style]

    content {
      deployment_option = deployment_style.value.deployment_option
      deployment_type   = deployment_style.value.deployment_type
    }
  }

  dynamic "ec2_tag_set" {
    for_each = length(var.ec2_tag_set) > 0 ? var.ec2_tag_set : []

    content {
      dynamic "ec2_tag_filter" {
        for_each = ec2_tag_set.value.ec2_tag_filter
        content {
          key   = lookup(ec2_tag_filter.value, "key", null)
          type  = lookup(ec2_tag_filter.value, "type", null)
          value = lookup(ec2_tag_filter.value, "value", null)
        }
      }
    }
  }

  dynamic "ecs_service" {
    for_each = var.ecs_service == null ? [] : var.ecs_service

    content {
      cluster_name = ecs_service.value.cluster_name
      service_name = ecs_service.value.service_name
    }
  }

  dynamic "load_balancer_info" {
    for_each = var.load_balancer_info == null ? [] : [var.load_balancer_info]

    content {
      dynamic "target_group_info" {
        for_each = lookup(load_balancer_info.value, "target_group_info", null) == null ? [] : flatten([lookup(load_balancer_info.value, "target_group_info", null)])

        content {
          name = tostring(try(target_group_info.value.name, target_group_info.value))
        }
      }

      dynamic "target_group_pair_info" {
        for_each = lookup(load_balancer_info.value, "target_group_pair_info", null) == null ? [] : flatten([lookup(load_balancer_info.value, "target_group_pair_info", null)])

        content {

          dynamic "prod_traffic_route" {
            for_each = lookup(target_group_pair_info.value, "prod_traffic_route", null) == null ? [] : flatten([lookup(target_group_pair_info.value, "prod_traffic_route", null)])

            content {
              listener_arns = prod_traffic_route.value.listener_arns
            }
          }

          dynamic "target_group" {
            for_each = lookup(target_group_pair_info.value, "target_group", null) == null ? [] : flatten([lookup(target_group_pair_info.value, "target_group", null)])

            content {
              name = tostring(try(target_group.value.name, target_group.value))
            }
          }

          dynamic "target_group" {
            for_each = lookup(target_group_pair_info.value, "blue_target_group", null) == null ? [] : flatten([lookup(target_group_pair_info.value, "blue_target_group", null)])

            content {
              name = tostring(try(target_group.value.name, target_group.value))
            }
          }

          dynamic "target_group" {
            for_each = lookup(target_group_pair_info.value, "green_target_group", null) == null ? [] : flatten([lookup(target_group_pair_info.value, "green_target_group", null)])

            content {
              name = tostring(try(target_group.value.name, target_group.value))
            }
          }

          dynamic "test_traffic_route" {
            for_each = lookup(target_group_pair_info.value, "test_traffic_route", null) == null ? [] : flatten([lookup(target_group_pair_info.value, "test_traffic_route", null)])

            content {
              listener_arns = test_traffic_route.value.listener_arns
            }
          }
        }
      }
    }
  }

  tags = var.deployment_group_tags
}