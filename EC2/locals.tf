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
      default_rtb_tags = {
        Name = "${local.parameter}-default-rtb"
      }

      vpc_tags = {
        Name        = "${local.parameter}-vpc"
      }

      enable_igw       = true
      enable_natgw     = true

      types = [
        {
          type         = "public"
          sn_cidrs     = ["10.0.0.0/24", "10.0.1.0/24"]
          sn_tags      = {
            Name = "${local.parameter}-public-$1"
          }

          rtb_tags     = {
            Name = "${local.parameter}-public-rtb"
          }

          igw_tags     = {
            Name = "${local.parameter}-igw"
          }
        },
        {
          type         = "private"
          sn_cidrs     = ["10.0.2.0/24", "10.0.3.0/24"]
          sn_tags      = {
            Name = "${local.parameter}-private-$1"
          }

          rtb_tags     = {
            Name       = "${local.parameter}-private-$1-rtb"
          }

          natgw_tags   = {
            Name = "${local.parameter}-natgw-$1"
          }
        },
      ]
    }
  }
}

locals {
  ec2s = {
    "${local.parameter}-bastion" = {
      vpc_name                = "${local.parameter}-vpc"
      subnet_name             = "${local.parameter}-public-a"

      instance_tags = {
        Name = "${local.parameter}-bastion"
      }
      
      instance_type           = "t2.micro"
      userdata                = "/ec2/bastion/userdata.sh"
      
      enable_public_ip        = true
      enable_eip              = true
      eip_tags = {
        Name = "${local.parameter}-bastion-eip"
      }

      root_block_device = {
        volume_size           = 10
        volume_type           = "gp3"
        delete_on_termination = true
      }


      security_group_name     = "${local.parameter}-ec2-sg"
      security_group_tags = {
        Name = "${local.parameter}-ec2-sg"
      }

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

      enable_create_iam_role = true
      iam_role_name         = "${local.parameter}-bastion-role"
      iam_role_tags         = {Name = "${local.parameter}-bastion-role"}
      instance_profile_name = "${local.parameter}-bastion-profile"
      iam_policies          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
  }
}