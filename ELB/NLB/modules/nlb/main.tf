resource "aws_lb" "this" {
  name                             = var.name
  internal                         = var.internal
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  load_balancer_type               = "network"
  subnets                          = var.subnet_ids
  
  tags = {
      Name = var.name
  } 
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
    path                = each.value.health_check.protocol == "TCP" ? null : each.value.health_check.path
    port                = each.value.health_check.port
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    matcher             = each.value.health_check.protocol == "TCP" ? null : each.value.health_check.matcher
  }

  tags = {
    Name = each.value.name
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[var.listener_target_groups].arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = var.enable_target ? { for t in var.targets : t.target_name => t } : {}

  target_group_arn = aws_lb_target_group.this[each.value.target_group_name].arn
  target_id        = var.ec2_info[each.value.target_name]
  port             = each.value.target_port
}