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