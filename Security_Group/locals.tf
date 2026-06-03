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
      default_rtb_tags = {Name = "${local.parameter}-default-rtb"}

      vpc_tags = {Name = "${local.parameter}-vpc"}

      enable_igw       = false
      enable_natgw     = false

      types = [
        {
          type         = "public"
          sn_cidrs     = ["10.0.0.0/24", "10.0.1.0/24"]
          sn_tags      = {Name = "${local.parameter}-public-$1"}

          rtb_tags     = {Name = "${local.parameter}-public-rtb"}

          igw_tags     = {Name = "${local.parameter}-igw"}
        },
      ]
    }
  }
}

locals {
  security_groups = {
    "${local.parameter}-app-sg" = {
      vpc_name = "${local.parameter}-vpc"

      security_group_name = "${local.parameter}-app-sg"
      security_group_tags = {Name = "${local.parameter}-app-sg"}
      ingress_ports = [{from_port = 8080, to_port = 8080, protocol = "tcp", cidr_block = "0.0.0.0/0"}]
      egress_ports = [{from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"}]
    },
    "${local.parameter}-alb-sg" = {
      vpc_name = "${local.parameter}-vpc"

      security_group_name = "${local.parameter}-alb-sg"
      security_group_tags = {Name = "${local.parameter}-alb-sg"}
      ingress_ports = [{from_port = 80, to_port = 80, protocol = "tcp", prefix_list_id = data.aws_ec2_managed_prefix_list.cloudfront.id}]
      egress_ports = [{from_port = 8080, to_port = 8080, protocol = "tcp", cidr_block = "0.0.0.0/0"}]
    },
  }
}