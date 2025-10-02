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

resource "aws_db_subnet_group" "this" {
  name       = var.subnet_group_name
  subnet_ids = var.protect_subnet_ids

  tags = {
    Name = var.subnet_group_name
  }
}

resource "aws_db_option_group" "this" {
  name                     = var.option_group_name
  option_group_description = var.option_group_name
  engine_name              = var.option_group_engine
  major_engine_version     = var.option_group_engine_version

  tags = {
    Name = var.option_group_name
  }
}

resource "aws_db_parameter_group" "this" {
  name        = var.parameter_group_name
  description = var.parameter_group_name
  family      = var.parameter_group_family

  tags = {
    Name = var.parameter_group_name
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.name
  instance_class         = var.class
  storage_type           = var.storage_type
  db_name                = var.db_name
  engine                 = var.engine
  engine_version         = var.engine_version
  username               = var.user_name
  password               = var.user_password
  port                   = var.port
  allocated_storage      = var.allocated_storage
  skip_final_snapshot    = var.skip_final_snapshot
  multi_az               = var.multi_az
  storage_encrypted      = var.storage_encrypted
  publicly_accessible    = var.publicly_accessible
  db_subnet_group_name   = aws_db_subnet_group.this.name
  option_group_name      = aws_db_option_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = var.name
  }
}