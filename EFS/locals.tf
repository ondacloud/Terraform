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
      ]
    }
  }
}

locals {
  kmss = {
    "${local.parameter}/efs/kms" = {
      tags = {
        Name = "${local.parameter}-efs-kms"
      }

      alias_name              = "alias/${local.parameter}/efs/kms"
      key_usage               = "ENCRYPT_DECRYPT"
      deletion_window_in_days = 7
    }
  }
}

locals {
  efss = {
    "${local.parameter}-efs" = {
      tags = {
        Name = "${local.parameter}-efs"
      }

      performance_mode                = "generalPurpose"
      encrypted                       = false
      kms_key_name                    = "${local.parameter}/efs/kms"
      throughput_mode                 = "bursting" # provisioned
      provisioned_throughput_in_mibps = 256

      enable_backup_policy            = false

      vpc_name                         = "${local.parameter}-vpc"

      security_group_name              = "${local.parameter}-efs-sg"
      security_group_tags = {
        Name = "${local.parameter}-efs-sg"
      }

      ingress_ports = [
        { from_port = 2049, to_port = 2049, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
      ]
    }
  }
}