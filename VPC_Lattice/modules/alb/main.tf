resource "aws_security_group" "this" {
  name   = var.security_group_name
  vpc_id = var.vpc_id

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

resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]
  subnets            = var.subnet_ids
  
  tags = var.alb_tags
}

resource "aws_lb_target_group" "this" {
  for_each = { for tg in var.target_groups : tg.name => tg }

  name                 = each.value.name
  port                 = each.value.port
  protocol             = each.value.protocol
  target_type          = each.value.target_type
  vpc_id               = var.vpc_id
  deregistration_delay = each.value.deregistration_delay

  health_check {
    protocol            = each.value.health_check.protocol
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    matcher             = each.value.health_check.matcher
  }

  tags = try(each.value.tags, {})
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.port
  protocol          = var.protocol

  dynamic "default_action" {
    for_each = [for act in var.default_action : act if try(act.enabled, false)]
    iterator = d_act

    content {
      type = d_act.value.type

      dynamic "forward" {
        for_each = try(d_act.value.type == "forward" ? [1] : [], [])
        content {
          dynamic "target_group" {
            for_each = try(d_act.value.forward_config.target_groups, [])
            content {
              arn    = aws_lb_target_group.this[target_group.value.name].arn
              weight = target_group.value.weight
            }
          }
        }
      }

      dynamic "fixed_response" {
        for_each = try(d_act.value.type == "fixed-response" ? [1] : [], [])
        content {
          content_type = try(d_act.value.fixed_response_config.content_type, "text/plain")
          message_body = try(d_act.value.fixed_response_config.message_body, "")
          status_code  = try(d_act.value.fixed_response_config.status_code, "200")
        }
      }
    }
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = { for rule in var.listener_rules : rule.name => rule if try(var.enable_listener_rules, false) }

  listener_arn = aws_lb_listener.this.arn
  priority     = each.value.priority

  dynamic "action" {
    for_each = flatten([each.value.action])
    iterator = act
    
    content {
      type = act.value.type

      dynamic "forward" {
        for_each = try(act.value.type == "forward" ? [1] : [], [])
        content {
          dynamic "target_group" {
            for_each = try(act.value.config.target_groups, [])
            content {
              arn    = aws_lb_target_group.this[target_group.value.name].arn
              weight = try(target_group.value.weight, 100)
            }
          }
        }
      }

      dynamic "fixed_response" {
        for_each = try(act.value.type == "fixed-response" ? [1] : [], [])
        content {
          content_type = try(act.value.config.content_type, "text/plain")
          message_body = try(act.value.config.message_body, "")
          status_code  = try(act.value.config.status_code, "200")
        }
      }
    }
  }

  dynamic "condition" {
    for_each = flatten([each.value.condition])
    iterator = cond

    content {
      dynamic "path_pattern" {
        for_each = try(cond.value.field == "path-pattern" ? [1] : [], [])
        content {
          values = try(cond.value.values, [])
        }
      }

      dynamic "host_header" {
        for_each = try(cond.value.field == "host-header" ? [1] : [], [])
        content {
          values = try(cond.value.values, [])
        }
      }
      
      dynamic "http_header" {
        for_each = try(cond.value.field == "http-header" ? [1] : [], [])
        content {
          http_header_name = try(cond.value.http_header_config.name, cond.value.header_name, null)
          values           = try(cond.value.http_header_config.values, cond.value.values, [])
        }
      }
      
      dynamic "http_request_method" {
        for_each = try(cond.value.field == "http-request-method" ? [1] : [], [])
        content {
          values = try(cond.value.values, [])
        }
      }
      
      dynamic "source_ip" {
        for_each = try(cond.value.field == "source-ip" ? [1] : [], [])
        content {
          values = try(cond.value.values, [])
        }
      }
    }
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = { for t in var.targets : t.target_name => t if var.enable_attach_target }

  target_group_arn = aws_lb_target_group.this[each.value.target_group_name].arn
  target_id        = var.target_info[each.value.target_name]
  port             = each.value.target_port
}