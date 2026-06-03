resource "aws_security_group" "this" {
  for_each = local.vpc_sg_map

  name   = each.key
  vpc_id = each.value.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = lookup(ingress.value, "cidr_block", null) != null ? [ingress.value.cidr_block] : null
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      protocol    = egress.value.protocol
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      cidr_blocks = lookup(egress.value, "cidr_block", null) != null ? [egress.value.cidr_block] : null
    }
  }

  tags = each.value.tags
}

resource "aws_vpclattice_service_network" "this" {
  name      = var.service_network_name
  auth_type = var.service_network_auth_type

  tags = var.service_network_tags
}

resource "aws_vpclattice_service_network_vpc_association" "this" {
  for_each = local.vpc_sg_map

  vpc_identifier             = each.value.vpc_id
  service_network_identifier = aws_vpclattice_service_network.this.id
  security_group_ids         = [aws_security_group.this[each.key].id]

  tags = var.service_network_vpc_tags
}

resource "aws_vpclattice_service" "this" {
  name      = var.service_name
  auth_type = var.service_auth_type

  tags = var.service_tags
}

resource "aws_vpclattice_service_network_service_association" "this" {
  service_identifier         = aws_vpclattice_service.this.id
  service_network_identifier = aws_vpclattice_service_network.this.id

  tags = var.service_association_tags
}

resource "aws_vpclattice_target_group" "this" {
  for_each = var.target_groups

  name = each.value.name
  type = each.value.type

  config {
    port                           = try(each.value.config.port, null)
    protocol                       = try(each.value.config.protocol, null)
    vpc_identifier                 = try(var.vpc_ids[each.value.config.vpc_identifier_name], null)
    ip_address_type                = try(each.value.config.ip_address_type, null)
    protocol_version               = try(each.value.config.protocol_version, null)
    lambda_event_structure_version = contains(["LAMBDA"], each.value.type) ? try(each.value.config.lambda_event_structure_version, null) : null

    dynamic "health_check" {
      for_each = !contains(["ALB", "LAMBDA"], each.value.type) && try(each.value.health_check, null) != null ? [each.value.health_check] : []

      content {
        enabled                       = try(health_check.value.enabled, true)
        health_check_interval_seconds = health_check.value.health_check_interval_seconds
        health_check_timeout_seconds  = health_check.value.health_check_timeout_seconds
        healthy_threshold_count       = health_check.value.healthy_threshold_count
        path                          = health_check.value.path
        port                          = health_check.value.port
        protocol                      = health_check.value.protocol
        protocol_version              = try(health_check.value.protocol_version, null)
        unhealthy_threshold_count     = health_check.value.unhealthy_threshold_count

        matcher {
          value = health_check.value.matcher
        }
      }
    }
  }

  tags = each.value.tags
}

resource "aws_vpclattice_target_group_attachment" "this" {
  for_each = var.enable_attach_target ? {for idx, target in var.targets : idx => target} : {}

  target_group_identifier = aws_vpclattice_target_group.this[each.value.target_group_name].id

  target {
    id   = var.alb_arn
    port = each.value.target_port
  }
}

resource "aws_vpclattice_listener" "this" {
  name               = var.listener_name
  service_identifier = aws_vpclattice_service.this.id
  protocol           = var.listener_protocol
  port               = var.listener_port

  default_action {
    forward {
      dynamic "target_groups" {
        for_each = var.default_forward_target_groups

        content {
          target_group_identifier = aws_vpclattice_target_group.this[target_groups.value.target_group_name].id
          weight                  = target_groups.value.weight
        }
      }
    }
  }
}

resource "aws_vpclattice_listener_rule" "this" {
  for_each = { for rule in var.listener_rules : rule.name => rule }

  name                = each.value.name
  listener_identifier = aws_vpclattice_listener.this.listener_id
  service_identifier  = aws_vpclattice_service.this.id
  priority            = each.value.priority

  match {
    http_match {
      header_matches {
        name = each.value.header_name

        match {
          exact = each.value.header_value
        }
      }
    }
  }

  action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.this[each.value.target_group_name].id
        weight                  = each.value.weight
      }
    }
  }
}