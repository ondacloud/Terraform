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

resource "aws_iam_role" "task" {
  count = var.enable_create_iam_role ? 1 : 0

  name = var.iam_task_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = var.iam_task_role_tags
}

resource "aws_iam_role_policy_attachment" "task" {
  for_each = var.enable_create_iam_role ? toset(var.iam_task_policies) : []

  role       = aws_iam_role.task[0].name
  policy_arn = each.value
}

resource "aws_iam_role" "exec" {
  count = var.enable_create_iam_role ? 1 : 0

  name = var.iam_exec_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = var.iam_exec_role_tags
}

resource "aws_iam_role_policy_attachment" "exec" {
  for_each = var.enable_create_iam_role ? toset(var.iam_exec_policies) : []

  role       = aws_iam_role.exec[0].name
  policy_arn = each.value
}

data "aws_iam_policy_document" "exec" {
  dynamic "statement" {
    for_each = var.statements
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = lookup(statement.value, "conditions", [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_policy" "exec_custom" {
  count  = var.enable_create_iam_role && var.enable_secrets_manager ? 1 : 0

  name   = var.iam_exec_policy_name
  policy = data.aws_iam_policy_document.exec.json
  tags   = var.iam_exec_policy_tags
}

resource "aws_iam_role_policy_attachment" "exec_custom_attach" {
  count      = var.enable_create_iam_role && var.enable_secrets_manager ? 1 : 0

  role       = aws_iam_role.exec[0].name
  policy_arn = aws_iam_policy.exec_custom[0].arn
}

resource "aws_iam_role" "ec2" {
  count = var.enable_create_iam_role ? 1 : 0

  name = var.iam_ec2_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = var.iam_ec2_role_tags
}

resource "aws_iam_role_policy_attachment" "ec2" {
  for_each = var.enable_create_iam_role ? toset(var.iam_ec2_policies) : []

  role       = aws_iam_role.ec2[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ec2" {
  count = var.enable_create_iam_role ? 1 : 0

  name = var.instance_profile_name
  role = aws_iam_role.ec2[0].name
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.cluster_container_insights
  }

  tags = var.cluster_tags
}

resource "aws_ecs_task_definition" "this" {
  for_each = var.taskdefinition

  family                   = each.key
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.enable_serverless ? ["FARGATE"] : ["EC2"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.exec[0].arn
  task_role_arn            = aws_iam_role.task[0].arn

  container_definitions = local.json_map[each.key]

  tags = each.value.tags
}

resource "aws_ecs_service" "this" {
  for_each = var.service

  name    = each.key
  cluster = aws_ecs_cluster.this.id

  task_definition = aws_ecs_task_definition.this[each.value.taskdefinition_name].arn
  launch_type     = each.value.enable_serverless ? "FARGATE" : "EC2"

  desired_count                      = each.value.desired_count
  deployment_maximum_percent         = each.value.deployment_maximum_percent
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = each.value.health_check_grace_period_seconds
  force_new_deployment               = each.value.force_new_deployment

  dynamic "network_configuration" {
    for_each = lookup(each.value, "network_mode", "awsvpc") == "awsvpc" ? ["true"] : []
    content {
      security_groups  = [aws_security_group.this.id]
      subnets          = var.subnet_ids
      assign_public_ip = var.internal ? false : true
    }
  }

  dynamic "load_balancer" {
    for_each = var.enable_load_balancers ? each.value.load_balancers : []
    content {
      target_group_arn = var.target_group_arns[load_balancer.value.target_group_name]
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  deployment_controller {
    type = each.value.deployment_controller_type
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer
    ]
  }
}
