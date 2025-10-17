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
  name                             = var.name
  internal                         = var.internal
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.this.id]
  subnets                          = var.subnet_ids
  
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
    protocol            = each.value.protocol
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    matcher             = each.value.health_check.matcher
  }

  tags =  each.value.tags
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    type = "forward"

    dynamic "forward" {
      for_each = [var.listener_target_groups]
      content {
        dynamic "target_group" {
          for_each = [for tg_name in forward.value : aws_lb_target_group.this[tg_name]]
          content {
            arn    = target_group.value.arn
            weight = 100 / length(forward.value)
          }
        }
      }
    }
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = var.enable_attach_target ? { for t in var.targets : t.target_name => t } : {}

  target_group_arn = aws_lb_target_group.this[each.value.target_group_name].arn
  target_id        = var.ec2_info[each.value.target_name]
  port             = each.value.target_port
}