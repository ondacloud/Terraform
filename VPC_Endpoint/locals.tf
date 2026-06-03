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

      enable_igw       = true
      enable_natgw     = false

      types = [
        {
          type         = "public"
          sn_cidrs     = ["10.0.0.0/24", "10.0.1.0/24"]
          sn_tags      = {Name = "${local.parameter}-public-$1"}

          rtb_tags     = {Name = "${local.parameter}-public-rtb"}

          igw_tags     = {Name = "${local.parameter}-igw"}
        },
        {
          type         = "workload"
          sn_cidrs     = ["10.0.2.0/24", "10.0.3.0/24"]
          sn_tags      = {Name = "${local.parameter}-workload-$1"}

          rtb_tags     = {Name = "${local.parameter}-workload-$1-rtb"}
        },
      ]
    }
  }
}

locals {
  security_groups = {
    "${local.parameter}-endpoint-sg" = {
      vpc_name = "${local.parameter}-vpc"

      security_group_name = "${local.parameter}-endpoint-sg"
      security_group_tags = {Name = "${local.parameter}-endpoint-sg"}
      ingress_ports = [{from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "0.0.0.0/0"}]
      egress_ports = [{from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"}]
    },
  }
}

locals {
  endpoints = {
    "ecr.dkr" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "ecr.dkr"
      endpoint_type       = "Interface"
      enable_private_dns  = true
      tags = {Name = "${local.parameter}-ecr-dkr-ep"}
    },
    "ecr.api" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "ecr.api"
      endpoint_type       = "Interface"
      enable_private_dns  = true
      tags = {Name = "${local.parameter}-ecr-api-ep"}
    },
    "ec2" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "ec2"
      endpoint_type       = "Interface"
      enable_private_dns  = true
      tags = {Name = "${local.parameter}-ec2-ep"}
    },
    "elb" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "elasticloadbalancing"
      endpoint_type       = "Interface"
      enable_private_dns  = true
      tags = {Name = "${local.parameter}-elb-ep"}
    },
    "kms" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "kms"
      endpoint_type       = "Interface"
      enable_private_dns  = true
      tags = {Name = "${local.parameter}-kms-ep"}
    },
    "logs" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "logs"
      endpoint_type       = "Interface"
      enable_private_dns  = true
      tags = {Name = "${local.parameter}-logs-ep"}
    },
    "sts" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "sts"
      endpoint_type       = "Interface"
      enable_private_dns  = true
      tags = {Name = "${local.parameter}-sts-ep"}
    },
    "eks" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "eks"
      endpoint_type       = "Interface"
      enable_private_dns  = false
      tags = {Name = "${local.parameter}-eks-ep"}
    },
    "eks-auth" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "eks-auth"
      endpoint_type       = "Interface"
      enable_private_dns  = false
      tags = {Name = "${local.parameter}-eks-auth-ep"}
    },
    "s3" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "s3"
      endpoint_type       = "Interface"
      enable_private_dns  = false
      tags = {Name = "${local.parameter}-s3-ep"}
    },
    "dynamodb" = {
      vpc_name            = "${local.parameter}-vpc"
      type                = "workload"
      security_group_name = "${local.parameter}-endpoint-sg"

      service_name        = "dynamodb"
      endpoint_type       = "Interface"
      enable_private_dns  = false
      tags = {Name = "${local.parameter}-dynamodb-ep"}
    },
  }
}