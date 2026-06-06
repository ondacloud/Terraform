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
    "${local.parameter}-a-vpc" = {
      vpc_cidr         = "10.0.0.0/16"
      default_rtb_tags = {Name = "${local.parameter}-a-default-rtb"}
      default_sg_tags  = {Name = "${local.parameter}-a-default-sg"}

      vpc_tags = {Name = "${local.parameter}-a-vpc"}

      enable_igw       = true
      enable_natgw     = true

      types = [
        {
          type         = "public"
          sn_cidrs     = ["10.0.0.0/24", "10.0.1.0/24"]
          sn_tags      = {Name = "${local.parameter}-a-public-$1"}

          rtb_tags     = {Name = "${local.parameter}-a-public-rtb"}

          igw_tags     = {Name = "${local.parameter}-a-igw"}
        },
        {
          type         = "private"
          sn_cidrs     = ["10.0.2.0/24", "10.0.3.0/24"]
          sn_tags      = {Name = "${local.parameter}-a-private-$1"}

          rtb_tags     = {Name = "${local.parameter}-a-private-$1-rtb"}

          natgw_tags   = {Name = "${local.parameter}-a-natgw-$1"}
        },
      ]
    },
    "${local.parameter}-b-vpc" = {
      vpc_cidr         = "192.168.0.0/16"
      default_rtb_tags = {Name = "${local.parameter}-b-default-rtb"}
      default_sg_tags  = {Name = "${local.parameter}-b-default-sg"}

      vpc_tags = {Name = "${local.parameter}-b-vpc"}

      enable_igw       = true
      enable_natgw     = true

      types = [
        {
          type         = "public"
          sn_cidrs     = ["192.168.0.0/24", "192.168.1.0/24"]
          sn_tags      = {Name = "${local.parameter}-b-public-$1"}

          rtb_tags     = {Name = "${local.parameter}-b-public-rtb"}

          igw_tags     = {Name = "${local.parameter}-b-igw"}
        },
        {
          type         = "private"
          sn_cidrs     = ["192.168.2.0/24", "192.168.3.0/24"]
          sn_tags      = {Name = "${local.parameter}-b-private-$1"}

          rtb_tags     = {Name = "${local.parameter}-b-private-$1-rtb"}

          natgw_tags   = {Name = "${local.parameter}-b-natgw-$1"}
        },
      ]
    }
  }
}

locals {
  vpc_peerings = {
    "${local.parameter}-vpc-peering" = {
      tags = {Name = "${local.parameter}-vpc-peering"}
      auto_accept = true

      requestor = {
        vpc_name = "${local.parameter}-a-vpc"
        route_table_names = ["${local.parameter}-a-public-rtb" ,"${local.parameter}-a-private-a-rtb", "${local.parameter}-a-private-c-rtb"]
        allow_remote_vpc_dns_resolution = true
      }

      accepter = {
        vpc_name = "${local.parameter}-b-vpc"
        route_table_names = ["${local.parameter}-b-public-rtb" ,"${local.parameter}-b-private-a-rtb", "${local.parameter}-b-private-c-rtb"]
        allow_remote_vpc_dns_resolution = true
      }
    }
  }
}