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
      enable_natgw     = true

      types = [
        {
          type         = "public"
          sn_cidrs     = ["10.0.0.0/24", "10.0.1.0/24"]
          sn_tags      = {Name = "${local.parameter}-public-$1"}

          rtb_tags     = {Name = "${local.parameter}-public-rtb"}

          igw_tags     = {Name = "${local.parameter}-igw"}
        },
        {
          type         = "private"
          sn_cidrs     = ["10.0.2.0/24", "10.0.3.0/24"]
          sn_tags      = {Name = "${local.parameter}-private-$1"}

          rtb_tags     = {Name       = "${local.parameter}-private-$1-rtb"}

          natgw_tags   = {Name = "${local.parameter}-natgw-$1"}
        },
      ]
    }
  }
}

locals {
  lambdas = {
    "${local.parameter}-function" = {
      tags = {Name = "${local.parameter}-function"}

      enable_lambda_edge = false
      enable_upload_zip  = false

      handler            = "lambda_function.lambda_handler"
      timeout            = 180
      runtime            = "python3.13"
      source_file_path   = "/lambda/lambda_function.py"
      output_file_path   = "/lambda/lambda_function_payload.zip"
      publish            = false

      iam_role_name      = "${local.parameter}-lambda-role"
      iam_role_tags      = {Name = "${local.parameter}-lambda-role"}
      iam_policies       = ["arn:aws:iam::aws:policy/AdministratorAccess"]

      enable_vpc_config = true
      vpc_name = "${local.parameter}-vpc"
      internal = true
      security_group_name = "${local.parameter}-lambda-sg"
      security_group_tags = {Name = "${local.parameter}-lambda-sg"}
      ingress_ports = []
      egress_ports = [{ from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "0.0.0.0/0"},]
    }
  }
}