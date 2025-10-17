resource "tls_private_key" "this" {
  count     = var.enable_create_keypair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  count      = var.enable_create_keypair ? 1 : 0
  key_name   = var.keypair_name
  public_key = tls_private_key.this[0].public_key_openssh
}

resource "local_file" "this" {
  count    = var.enable_create_keypair ? 1 : 0
  content  = tls_private_key.this[0].private_key_pem
  filename = var.keypair_file_path
}

resource "aws_iam_role" "this" {
  count = var.enable_create_iam_role ? 1 : 0

  name               = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.enable_create_iam_role ? toset(try(var.iam_policies, [])) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.enable_create_iam_role ? 1 : 0

  name = var.instance_profile_name
  role = aws_iam_role.this[0].name
}

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

resource "aws_launch_template" "this" {
  name                   = var.name
  image_id               = data.aws_ssm_parameter.latest_ami.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.enable_create_keypair ? aws_key_pair.this[0].key_name : var.keypair_name
  user_data              = filebase64("${path.module}/../../src/${var.userdata}")

  dynamic "iam_instance_profile" {
    for_each = var.enable_create_iam_role ? [1] : []
    content {
      arn = aws_iam_instance_profile.this[0].arn
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }
  
  dynamic "tag_specifications" {
    for_each = var.tag_specifications != null ? var.tag_specifications : []

    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings != null ? var.block_device_mappings : []

    content {
      device_name = block_device_mappings.value.device_name

      dynamic "ebs" {
        for_each = block_device_mappings.value.ebs != null ? [block_device_mappings.value.ebs] : []

        content {
          volume_size           = ebs.value.volume_size
          volume_type           = ebs.value.volume_type
          delete_on_termination = ebs.value.delete_on_termination
        }
      }
    }
  }

  tags = var.tags
}