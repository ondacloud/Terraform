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

resource "aws_elasticache_serverless_cache" "this" {
  engine = "redis"
  name   = var.name
  major_engine_version = var.engine_version
  security_group_ids   = [aws_security_group.this.id]
  subnet_ids           = var.protect_subnet_ids
  
  cache_usage_limits {
    data_storage {
      minimum = var.data_storage.minimum
      maximum = var.data_storage.maximum
      unit    = var.data_storage.unit
    }

    ecpu_per_second {
      minimum = var.ecpu_per_second.minimum
      maximum = var.ecpu_per_second.maximum
    }
  }

  tags = {
    Name = var.name
  }
}