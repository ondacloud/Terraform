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
  albs = {
    "${local.parameter}-alb" = {
      vpc_name                = "${local.parameter}-vpc"

      internal                  = true
      port                      = 80
      protocol                  = "HTTP"
      listener_target_groups    = ["${local.parameter}-alb-tg"]

      target_groups = [
        {
          name                  = "${local.parameter}-alb-tg"
          port                  = 80
          protocol              = "HTTP"
          target_type           = "instance" # instance or ip or lambda or alb
          deregistration_delay  = 30

          health_check = {
            protocol            = "HTTP"
            path                = "/"
            port                = 80
            interval            = 5
            timeout             = 2
            healthy_threshold   = 2
            unhealthy_threshold = 2
            matcher             = "200-399"
          }
        }
      ]

      enable_target             = false
      targets = [
        {
          type                  = "ec2"
          target_group_name     = "${local.parameter}-alb-tg"
          target_name           = "${local.parameter}-bastion"
          target_port           = 80
        },
      ]

      security_group_name     = "${local.parameter}-alb-sg"

      ingress_ports = [
        { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
      ]
    }
  }
}