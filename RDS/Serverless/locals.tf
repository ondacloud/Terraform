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
      ]
    }
  }
}

locals {
  rdss = {
    "${local.parameter}-db-cluster" = {
      vpc_name                        = "${local.parameter}-vpc"

      db_name                         = "${local.parameter}"
      cw_logs_exports                 = ["audit", "error", "general", "slowquery"]
      engine                          = "aurora-mysql"
      engine_mode                     = "provisioned" # serverless
      user_name                       = "admin"
      user_password                   = "Skill53##"
      port                            = 3306
      serverless_min_capacity         = 2
      serverless_max_capacity         = 8
      backtrack_window                = 14400
      skip_final_snapshot             = true
      storage_encrypted               = true
      performance_insights_enabled    = false

      instance_name                   = "${local.parameter}-db-instance"
      instance_count                  = 1
      instance_class                  = "db.serverless"
      instance_engine                 = "aurora-mysql"

      subnet_group_name               = "${local.parameter}-db-sg"

      cluster_parmeter_group_name     = "${local.parameter}-db-cpg"
      cluster_parmeter_group_family   = "aurora-mysql8.0"

      parameter_group_name            = "${local.parameter}-db-pg"
      parameter_group_family          = "aurora-mysql8.0"

      security_group_name             = "${local.parameter}-rds-sg"

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
    rds = {
      name     = "${local.parameter}-rds-secrets"
      rds_name = "${local.parameter}-db-cluster"
    }
  }
}