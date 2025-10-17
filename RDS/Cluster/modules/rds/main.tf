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

resource "aws_db_subnet_group" "this" {
  name       = var.subnet_group_name
  subnet_ids = var.protect_subnet_ids

  tags = var.subnet_group_tags
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = var.cluster_parameter_group_name
  description = var.cluster_parameter_group_name
  family      = var.cluster_parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = var.cluster_parameter_group_tags
}

resource "aws_db_parameter_group" "this" {
  name        = var.parameter_group_name
  description = var.parameter_group_name
  family      = var.parameter_group_family

  tags = var.parameter_group_tags
}

resource "aws_rds_cluster" "this" {

  cluster_identifier              = var.name
  database_name                   = var.db_name
  availability_zones              = var.availability_zones
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
  enabled_cloudwatch_logs_exports = var.cw_logs_exports
  engine                          = var.engine
  master_username                 = var.user_name
  master_password                 = var.user_password
  port                            = var.port
  backtrack_window                = var.backtrack_window
  skip_final_snapshot             = var.skip_final_snapshot
  storage_encrypted               = var.storage_encrypted
  performance_insights_enabled    = var.performance_insights_enabled

  tags = var.rds_cluster_tags
}

resource "aws_rds_cluster_instance" "this" {
  count                   = var.instance_count
  cluster_identifier      = aws_rds_cluster.this.id
  db_subnet_group_name    = aws_db_subnet_group.this.name
  db_parameter_group_name = aws_db_parameter_group.this.name
  instance_class          = var.instance_class
  identifier              = "${var.instance_name}-${count.index}"
  engine                  = var.instance_engine

  tags = merge(
    var.instance_tags,
    {Name = "${var.instance_tags["Name"]}-${count.index}"}
  )
}