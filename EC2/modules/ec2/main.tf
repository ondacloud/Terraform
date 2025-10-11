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

resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.latest_ami.value
  subnet_id                   = var.subnet_id
  instance_type               = var.instance_type
  key_name                    = var.enable_create_keypair ? aws_key_pair.this[0].key_name : var.keypair_name
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = var.enable_public_ip
  iam_instance_profile        = var.enable_create_iam_role ? aws_iam_instance_profile.this[0].name : null
  root_block_device {
    volume_size               = 10
    volume_type               = "gp3"
    delete_on_termination     = true
  }

  user_data = file("${path.module}/../../src/${var.userdata}")

  tags = var.instance_tags
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
  for_each = var.enable_create_iam_role ? toset(var.iam_policies) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.enable_create_iam_role ? 1 : 0

  name = var.instance_profile_name
  role = aws_iam_role.this[0].name
}

resource "aws_eip" "this" {
  count = var.enable_eip ? 1 : 0

  instance                  = aws_instance.this.id
  associate_with_private_ip = aws_instance.this.private_ip

  tags = var.eip_tags
}
