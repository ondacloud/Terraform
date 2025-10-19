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
        {
          type         = "protect"
          sn_cidrs     = ["10.0.4.0/24", "10.0.5.0/24"]
          sn_tags      = {
            Name = "${local.parameter}-protect-$1"
          }

          rtb_tags     = {
            Name = "${local.parameter}-protect-rtb"
          }
        },
      ]
    }
  }
}

locals {
  elaticaches = {
    "${local.parameter}-memcached-cluster" = {
      vpc_name                        = "${local.parameter}-vpc"

      engine                          = "memcached"
      engine_version                  = "1.6.17"
      node_type                       = "cache.t4g.small"
      az_mode                         = "cross-az" # single-az
      num_cache_nodes                 = 2
      port                            = 11211
      apply_immediately               = true


      subnet_group_name               = "${local.parameter}-memcached-sg"

      parameter_group_name            = "${local.parameter}-memcached-pg"
      parameter_group_family          = "memcached1.6"
      parameters = [
        {
          name  = "idle_timeout"
          value = 60
        }
      ]

      security_group_name             = "${local.parameter}-memcached-sg"

      ingress_ports = [
        { from_port = 11211, to_port = 11211, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
      ]
    }
  }
}