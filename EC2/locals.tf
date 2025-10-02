locals {
  parameter = "demo"

  az_override  = ["a", "c"]

  azs = [
    for az in data.aws_availability_zones.az.names :
    az if contains(local.az_override, substr(az, -1, 1))
  ]
}

locals {
  vpcs = {
    "${local.parameter}-vpc" = {
      vpc_cidr         = "10.0.0.0/16"
      default_rtb_name = "${local.parameter}-default-rtb"

      enable_igw       = true
      enable_natgw     = true

      types = [
        {
          type         = "public"
          sn_name      = "${local.parameter}-public-$1"
          sn_cidrs     = ["10.0.0.0/24", "10.0.1.0/24"]
          rtb_name     = "${local.parameter}-public-rtb"
          igw_name     = "${local.parameter}-igw"
        },
        {
          type         = "private"
          sn_name      = "${local.parameter}-private-$1"
          sn_cidrs     = ["10.0.2.0/24", "10.0.3.0/24"]
          rtb_name     = "${local.parameter}-private-$1-rtb"
          natgw_name   = "${local.parameter}-natgw-$1"
        },
        {
          type         = "protect"
          sn_name      = "${local.parameter}-protect-$1"
          sn_cidrs     = ["10.0.4.0/24", "10.0.5.0/24"]
          rtb_name     = "${local.parameter}-protect-rtb"
        },
        {
          type         = "inspect"
          sn_name      = "${local.parameter}-inspect-$1"
          sn_cidrs     = ["10.0.6.0/24", "10.0.7.0/24"]
          rtb_name     = "${local.parameter}-inspect-$1-rtb"
        }
      ]
    }
  }
}

locals {
  ec2s = {
    bastion = {
      vpc_name                = "${local.parameter}-vpc"
      subnet_name             = "${local.parameter}-public-a"
      
      name                    = "${local.parameter}-bastion"
      security_group_name     = "${local.parameter}-ec2-sg"
      instance_type           = "t3.micro"
      userdata                = "/bastion/userdata.sh"
      
      enable_public_ip        = true
      enable_eip              = true

      ingress_ports = [
        { from_port = 22, to_port = 22, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
        # { from_port = 22, to_port = 22, protocol = "tcp", cidr_block = "0.0.0.0/0"},
        # { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0"},
        # { from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "0.0.0.0/0"}
      ]
      
      enable_create_keypair = true
      keypair_name          = "${local.parameter}"
      keypair_file_path     = "${path.cwd}/${local.parameter}.pem"

      iam_role_name         = "${local.parameter}-bastion-role"
      instance_profile_name = "${local.parameter}-bastion-profile"
      iam_policies          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
  }
}