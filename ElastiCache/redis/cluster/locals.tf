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
    "${local.parameter}-redis-cluster" = {
      vpc_name                        = "${local.parameter}-vpc"

      engine                          = "redis"
      engine_version                  = "7.1"
      node_type                       = "cache.t4g.small"
      az_mode                         = "single-az"
      num_cache_nodes                 = 1
      port                            = 6379
      apply_immediately               = true

      subnet_group_name               = "${local.parameter}-redis-sg"

      parameter_group_name            = "${local.parameter}-redis-pg"
      parameter_group_family          = "redis7"
      parameters = [
        {
          name  = "idle_timeout"
          value = 60
        },
        {
          name  = "latency-tracking"
          value = "yes"
        }
      ]

      security_group_name             = "${local.parameter}-redis-sg"

      ingress_ports = [
        { from_port = 6379, to_port = 6379, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
      ]
    }
  }
}