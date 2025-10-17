resource "aws_autoscaling_group" "this" {
  name                      = var.name
  vpc_zone_identifier       = var.subnet_ids


  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  target_group_arns         = var.enable_attach_elb && var.elb_target_group_arn != "" ? [var.elb_target_group_arn] : []

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  timeouts {
    delete = var.timeout_delete_time
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = var.tags_no_launch
    }
  }
}

resource "aws_autoscaling_traffic_source_attachment" "this" {
  count = var.enable_attach_elb ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.this.name

  traffic_source {
    identifier = var.elb_target_group_arn
    type       = "elbv2" 
  }
}

resource "aws_autoscaling_policy" "this" {
  for_each = var.enable_scaling_policy ?  { for p in var.scaling_policys : p.name => p } : {}

  name                   = each.value.name
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = each.value.policy_type

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = each.value.target_tracking_configuration.predefined_metric_specification.predefined_metric_type
      resource_label = each.value.target_tracking_configuration.predefined_metric_specification.predefined_metric_type == "ALBRequestCountPerTarget" ? "${var.elb_arn_suffix}/${var.elb_target_group_arn_suffix}" : null
    }
    target_value     = each.value.target_tracking_configuration.target_value
    disable_scale_in = each.value.target_tracking_configuration.disable_scale_in
  }
}