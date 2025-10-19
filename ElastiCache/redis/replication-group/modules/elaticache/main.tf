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

  tags = {
    Name = var.security_group_name
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = var.subnet_group_name
  subnet_ids = var.protect_subnet_ids

  tags = {
    Name = var.subnet_group_name
  }
}

resource "aws_elasticache_parameter_group" "this" {
  name   = var.parameter_group_name
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = {
    Name = var.parameter_group_name
  }
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id        = var.name
  description                 = var.name
  node_type                   = var.node_type
  engine                      = var.engine
  engine_version              = var.engine_version
  num_node_groups             = var.num_node_groups
  replicas_per_node_group     = var.replicas_per_node_group
  automatic_failover_enabled  = var.automatic_failover_enabled
  multi_az_enabled            = var.multi_az_enabled
  apply_immediately           = var.apply_immediately
  at_rest_encryption_enabled  = var.at_rest_encryption_enabled
  port                        = var.port
  security_group_ids          = [aws_security_group.this.id]
  subnet_group_name           = aws_elasticache_subnet_group.this.name
  parameter_group_name        = aws_elasticache_parameter_group.this.name
  transit_encryption_enabled  = var.transit_encryption_enabled
  transit_encryption_mode     = var.transit_encryption_mode

  tags = {
    Name = var.name
  }
}