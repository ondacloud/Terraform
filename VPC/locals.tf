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
            environment = "demo"
          }

          rtb_tags     = {
            Name = "${local.parameter}-public-rtb"
            environment = "demo"
          }

          igw_tags     = {
            Name = "${local.parameter}-igw"
            environment = "demo"
          }
        },
        {
          type         = "private"
          sn_cidrs     = ["10.0.2.0/24", "10.0.3.0/24"]
          sn_tags      = {
            Name = "${local.parameter}-private-$1"
            environment = "demo"
          }

          rtb_tags     = {
            Name       = "${local.parameter}-private-$1-rtb"
            environment = "demo"
          }

          natgw_tags   = {
            Name = "${local.parameter}-natgw-$1"
            environment = "demo"
          }
        },
        {
          type         = "protect"
          sn_cidrs     = ["10.0.4.0/24", "10.0.5.0/24"]
          sn_tags      = {
            Name = "${local.parameter}-protect-$1"
            environment = "demo"
          }

          rtb_tags     = {
            Name = "${local.parameter}-protect-rtb"
            environment = "demo"
          }
        },
        {
          type         = "inspect"
          sn_cidrs     = ["10.0.6.0/24", "10.0.7.0/24"]
          sn_tags      = {
            Name = "${local.parameter}-inspect-$1"
            environment = "demo"
          }

          rtb_tags     = {
            Name = "${local.parameter}-inspect-$1-rtb"
            environment = "demo"
          }
        }
      ]
    }
  }
}