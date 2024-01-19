resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "<env>-vpc"
  }
}

# Public

## Internet Gateway
resource"aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-IGW"
  }
}

## Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-public-rt"
  }
}
 
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

## Public Subnet
resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-public-b"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-public-c"
  }
}

## Attach Public Subnet in Route Table
resource "aws_route_table_association" "public_a" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

# Private

## Elastic IP
resource "aws_eip" "private_a" {
}

resource "aws_eip" "private_b" {
}

resource "aws_eip" "private_c" {
}

## NAT Gateway
resource "aws_nat_gateway" "private_a" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_a.id
  subnet_id = aws_subnet.public_a.id

  tags = {
    Name = "<env>-NGW-a"
  }
}

resource "aws_nat_gateway" "private_b" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_b.id
  subnet_id = aws_subnet.public_b.id

  tags = {
    Name = "<env>-NGW-b"
  }
}

resource "aws_nat_gateway" "private_c" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_c.id
  subnet_id = aws_subnet.public_c.id

  tags = {
    Name = "<env>-NGW-c"
  }
}

## Route Table
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-private-a-rt"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-private-b-rt"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-private-c-rt"
  }
}

resource "aws_route" "private_a" {
  route_table_id = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_a.id
}

resource "aws_route" "private_b" {
  route_table_id = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_b.id
}

resource "aws_route" "private_c" {
  route_table_id = aws_route_table.private_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_c.id
}

resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "<env>-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "<env>-private-b"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "<env>-private-c"
  }
}

# Product

#Route Table
resource "aws_route_table" "product_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-product-a-rt"
  }
}
 
resource "aws_route_table" "product_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-product-b-rt"
  }
}

resource "aws_route_table" "product_c" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-product-c-rt"
  }
}

## Product Subnet
resource "aws_subnet" "product_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "<env>-product-a"
  }
}

resource "aws_subnet" "product_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.7.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "<env>-product-b"
  }
}

resource "aws_subnet" "product_c" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.8.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "<env>-product-c"
  }
}

## Attach Product Subnet in Route Table
resource "aws_route_table_association" "product_a" {
  subnet_id = aws_subnet.product_a.id
  route_table_id = aws_route_table.product_a.id
}

resource "aws_route_table_association" "product_b" {
  subnet_id = aws_subnet.product_b.id
  route_table_id = aws_route_table.product_b.id
}

resource "aws_route_table_association" "product_c" {
  subnet_id = aws_subnet.product_c.id
  route_table_id = aws_route_table.product_c.id
}


## Attach Private Subnet in Route Table
resource "aws_route_table_association" "private_a" {
  subnet_id = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}

# EC2
## AMI
data "aws_ssm_parameter" "latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-x86_64"
}

## Public EC2
resource "aws_instacne" "bastion" {
  ami = data.aws_ssm_parameter.latest_ami.value
  subnet_id = aws_subnet.public_a.id
  instance_type = "<Type>"
  key_name = "<env>"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  ...
  EOF
  tags = {
    Name = "<env>-bastion-ec2"
  }
}

## Public Security Group
resource "aws_security_group" "bastion" {
  name = "<env>-EC2-SG"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "<Port>"
    to_port = "<Port>"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "<Port>"
    to_port = "<Port>"
  }
 
    tags = {
    Name = "<env>-EC2-SG"
  }
}

## IAM
resource "aws_iam_role" "bastion" {
  name = "<env>-role-bastion"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_instance_profile" "bastion" {
  name = "<env>-profile-bastion"
  role = aws_iam_role.bastion.name
}

# OutPut

## VPC
output "aws_vpc" {
  value = aws_vpc.main.id
}

## Public Subnet
output "public_a" {
  value = aws_subnet.public_a.id
}

output "public_b" {
  value = aws_subnet.public_b.id
}

output "public_c" {
  value = aws_subnet.public_c.id
}

## Private Subnet
output "private_a" {
  value = aws_subnet.private_a.id
}

output "private_b" {
  value = aws_subnet.private_b.id
}

output "private_c" {
  value = aws_subnet.private_c.id
}

output "product_a" {
    value = aws_subnet.product_a.id
}

output "product_b" {
    value = aws_subnet.product_b.id
}

output "product_c" {
    value = aws_subnet.product_c.id
}

output "bastion" {
  value = aws_instacne.bastion.id
}

output "bastion-sg" {
  value = aws_security_group.bastion.id
}