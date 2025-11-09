locals {
  parameter = "demo"

  az_override  = ["a", "c"]

  azs = [
    for az in data.aws_availability_zones.az.names :
    az if contains(local.az_override, substr(az, -1, 1))
  ]
}

locals {
  github ={
    user_name = "demo"
    repository_name = "demo-repository"
    access_token  = "ghp_demo-token"
  }
}

locals {
  codebuilds = {
    "${local.parameter}-build" = {
      tags = {
        Name = "${local.parameter}-build"
      }

      build_compute_type                 = "BUILD_GENERAL1_SMALL"
      build_image                        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
      build_image_pull_credentials_type  = "CODEBUILD"
      build_type                         = "LINUX_CONTAINER"
      privileged_mode                    = false

      buildspec                          = "buildspec.yml"
      source_type                        = "GITHUB"
      source_location                    = "https://github.com/${local.github.user_name}/${local.github.repository_name}.git"
      report_build_status                = true

      artifact_type                      = "NO_ARTIFACTS" # CODEPIPELINE
      enable_cache                       = false
      cache_config = {
        type     = "S3"
        location = "${local.parameter}-buckets/cache"
        modes    = "LOCAL_DOCKER_LAYER_CACHE"
      }

      enable_environment_variable = false
      environment_variables = [
        {name  = "REGION_CODE", value = "ap-northeast-2"},
      ]

      enable_vpc_config = false
      vpc_name = "${local.parameter}-vpc"
      internal = true
      security_group_name     = "${local.parameter}-codebuild-sg"
      security_group_tags = {
        Name = "${local.parameter}-codebuild-sg"
      }

      ingress_ports = [
        { from_port = 2049, to_port = 2049, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
        # { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0"},
        # { from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "0.0.0.0/0"}
      ]
      
      enable_logs = true
      logs_config = {
        cloudwatch_logs = {
          status      = "ENABLED"
          group_name  = "/codebuild/${local.parameter}-build"
          stream_name = "build-log"
        }
        s3_logs = {
          status              = "DISABLED"
          location            = null 
          encryption_disabled = false
        }
      }

      enable_file_system = false
      efs_name           = "${local.parameter}-efs"
      mount_path         = "/build"
      mount_point        = "/mnt/efs"

      enable_iam_role = true
      role_name   = "${local.parameter}-build-role"
      role_tags   = {Name = "${local.parameter}-build-role"}
      policy_name = "${local.parameter}-policy"
      policy_tags = {Name = "${local.parameter}-build-policy"}
      iam_role_arn = "arn:aws:iam::${data.aws_caller_identity.caller.account_id}:role/${local.parameter}-build-role"

      statements = [
        {
          effect    = "Allow"
          actions   = ["logs:*", "s3:*", "ecr:*", "codestar-connections:*"] # EC2, EFS
          resources = ["*"]
          conditions = []
        }
      ]

    }
  }
}