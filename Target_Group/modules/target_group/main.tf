resource "aws_lb_target_group" "this" {
  for_each = { for tg in var.target_groups : tg.name => tg }

  name                 = each.value.name
  port                 = each.value.target_type == "lambda" ? null : each.value.port
  protocol             = each.value.protocol
  target_type          = each.value.target_type
  vpc_id               = each.value.target_type == "lambda" ? null : each.value.vpc_id
  deregistration_delay = each.value.deregistration_delay

  dynamic "health_check" {
    for_each = each.value.target_type == "lambda" ? [] : [1]

    content {
      protocol            = each.value.health_check.protocol
      path                = each.value.health_check.path
      port                = each.value.health_check.port
      interval            = each.value.health_check.interval
      timeout             = each.value.health_check.timeout
      healthy_threshold   = each.value.health_check.healthy_threshold
      unhealthy_threshold = each.value.health_check.unhealthy_threshold
      matcher             = each.value.health_check.matcher
    } 
  }
  tags =  each.value.tags
}

resource "aws_lb_target_group_attachment" "this" {
  depends_on = [aws_lambda_permission.this]

  for_each = var.enable_attach_target ? {for t in var.targets : t.target_name => t} : {}

  target_group_arn = aws_lb_target_group.this[each.value.target_group_name].arn
  target_id        = var.target_info[each.value.target_name]
  port = aws_lb_target_group.this[each.value.target_group_name].target_type == "lambda" ? null : each.value.target_port
}

resource "aws_lambda_permission" "this" {
  for_each = var.enable_attach_target ? { for t in var.targets : t.target_name => t } : {}
  statement_id  = "AllowExecutionFromELB-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = var.target_info[each.value.target_name]
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.this[each.value.target_group_name].arn
}