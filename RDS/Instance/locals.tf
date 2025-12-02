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
  rdss = {
    "${local.parameter}-db-instance" = {
      vpc_name                        = "${local.parameter}-vpc"

      instance_tags = {
        Name = "${local.parameter}-db-instance"
      }

      db_name                         = "${local.parameter}"
      class                           = "db.t3.medium"
      storage_type                    = "gp3"
      engine                          = "mysql"
      engine_version                  = "8.0"
      user_name                       = "admin"
      user_password                   = "Skill53##"
      port                            = 3306
      allocated_storage               = 20
      skip_final_snapshot             = true
      multi_az                        = true
      storage_encrypted               = true
      publicly_accessible             = false

      subnet_group_name               = "${local.parameter}-db-sg"
      subnet_group_tags               = {
        Name = "${local.parameter}-db-sg"
      }

      option_group_name               = "${local.parameter}-db-og"
      option_group_engine             = "mysql"
      option_group_engine_version     = "8.0"
      option_group_tags               = {
        Name = "${local.parameter}-db-og"
      }

      parameter_group_name            = "${local.parameter}-db-pg"
      parameter_group_family          = "mysql8.0"
      parameter_group_tags            = {
        Name = "${local.parameter}-db-pg"
      }

      security_group_name             = "${local.parameter}-rds-sg"
      security_group_tags             = {
        Name = "${local.parameter}-rds-sg"
      }

      ingress_ports = [
        { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
      ]
    }
  }
}

locals {
  secrets_managers = {
    "${local.parameter}-rds-secrets" = {
      tags = {
        Name = "${local.parameter}-rds-secrets"
      }
      
      rds_name      = "${local.parameter}-db-instance"
      enable_values = false
    }
  }
}