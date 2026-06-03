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
    user_name       = "demo-user"
    repository_name = "demo-repository"
    branch_name     = "main"
    access_token    = "ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  }
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
          sn_tags      = {Name = "${local.parameter}-public-sn-$1"}

          rtb_tags     = {Name = "${local.parameter}-public-rtb"}

          igw_tags     = {Name = "${local.parameter}-igw"}
        },
        {
          type         = "private"
          sn_cidrs     = ["10.0.2.0/24", "10.0.3.0/24"]
          sn_tags      = {Name = "${local.parameter}-private-sn-$1"}

          rtb_tags     = {Name = "${local.parameter}-private-$1-rtb"}

          natgw_tags   = {Name = "${local.parameter}-natgw-$1"}
        },
      ]
    }
  }
}

locals {
  albs = {
    "${local.parameter}-alb" = {
      vpc_name              = "${local.parameter}-vpc"

      alb_tags              = {Name = "${local.parameter}-alb"}
      internal              = true
      port                  = 80
      protocol              = "HTTP"

      default_action = [
        {
          enabled = true
          type    = "forward"
          forward_config = {
            target_groups = [
              { name = "${local.parameter}-alb-tg", weight = 100},
            ]
          }
        },
        {
          enabled = false
          type    = "fixed-response"
          fixed_response_config = {
            content_type = "text/plain"
            status_code  = 404
            message_body = "Not Found"
          }
        }
      ]

      enable_listener_rules = false
      listener_rules = [
        {
          name = "path-fixed-response"
          priority = 1
          condition = [
            {
              field  = "path-pattern"
              values = ["/healthcheck"]
            },
          ]
          action = [
            {
              type = "fixed-response",
              config = {
                content_type = "text/plain",
                status_code  = 404,
                message_body = "Restrict access to api"
              }
            }
          ]
        },
        {
          name = "path-forward"
          priority = 2
          condition = [
            {field = "path-pattern", values = ["/version"]},
          ]
          action = {
            type = "forward"
            config = {
              target_groups = [
                {name = "${local.parameter}-alb-tg", weight = 100},
              ]
            }
          }
        },
        {
          name = "path-and-header-forward"
          priority = 3
          condition = [
            {field = "path-pattern", values = ["/version"]},
            {field = "http-header", http_header_config = {name = "version", values = ["v1"]}}
          ]
          action = {
            type = "forward"
            config = {
              target_groups = [
                {name = "${local.parameter}-alb-tg", weight = 100},
              ]
            }
          }
        },
      ]

      target_groups = [
        {
          name                 = "${local.parameter}-alb-tg"
          port                 = 80
          protocol             = "HTTP"
          target_type          = "instance" # instance or ip or lambda or alb
          deregistration_delay  = 30
          tags                 = { Name = "${local.parameter}-alb-tg" }

          health_check = {
            protocol            = "HTTP"
            path                = "/"
            port                = 80
            interval            = 5
            timeout             = 2
            healthy_threshold   = 2
            unhealthy_threshold = 2
            matcher             = "200-399"
          }
        },
      ]

      enable_attach_target      = false
      targets = [
        {
          type                  = "ec2"
          target_group_name     = "${local.parameter}-alb-tg"
          target_name           = "${local.parameter}-app"
          target_port           = 80
        },
      ]

      security_group_name     = "${local.parameter}-alb-sg"
      security_group_tags = {Name = "${local.parameter}-alb-sg"}

      ingress_ports = [{ from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0"},]

      egress_ports = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},]
    }
  }
}

locals {
  ecrs = {
    "${local.parameter}-repo" = {
      tags = {
        Name = "${local.parameter}-repo"
      }

      image_tag_mutability              = "MUTABLE"
      force_delete                      = true
      scan_images_on_push               = true

      enable_kms                        = false
      kms_key_name                      = "${local.parameter}/ecr/kms"
      encryption_type                   = "KMS"

      enable_image_tag_exclusion_filter = false
      image_tag_exclusion_filter = [
        {filter = "latest", filter_type = "WILDCARD"},
      ]
    }
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
      privileged_mode                    = true

      buildspec                          = "buildspec.yml"
      source_type                        = "CODEPIPELINE"
      source_location                    = "https://github.com/${local.github.user_name}/${local.github.repository_name}.git"
      report_build_status                = true

      artifact_type                      = "CODEPIPELINE"
      enable_cache                       = true
      cache_config = {
        type     = "S3" # LOCAL
        location = "${local.parameter}-build-cache-buckets"
        # modes    = "LOCAL_DOCKER_LAYER_CACHE" # LOCAL_SOURCE_CACHE
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

locals {
  codedeploys = {
    "${local.parameter}-app" = {
      app_tags = { Name = "${local.parameter}-app" }

      compute_platform       = "Server"
      deployment_config_name = "${local.parameter}-deploy-config"

      deployment_group_name = "${local.parameter}-deploy"
      deployment_group_tags = { Name = "${local.parameter}-deploym" }

      outpdated_instances_strategy = "UPDATE" # IGNORE

      auto_rollback_configuration_enabled = true
      auto_rollback_configuration_events  = "DEPLOYMENT_FAILURE"

      deployment_style = {
        deployment_option = "WITH_TRAFFIC_CONTROL" # WITHOUT_TRAFFIC_CONTROL
        deployment_type   = "IN_PLACE" # BLUE_GREEN
      }

      ec2_tag_set = [
        {
          ec2_tag_filter = [
            { key = "environment", type = "KEY_AND_VALUE", value = "application" }
          ]
        }
      ]

      minimum_healthy_hosts = { type = "HOST_COUNT", value = 1 }
      load_balancer_info = {
        target_group_info = [{ name = "${local.parameter}-alb-tg" }]
      }

      enable_iam_role = true
      iam_role_name   = "${local.parameter}-deploy-role"
      iam_role_tags   = { Name = "${local.parameter}-deploy-role" }
      iam_policy_name = "${local.parameter}-deploy-policy"
      iam_policy_tags = { Name = "${local.parameter}-deploy-policy" }

      statements = [
        {
          sid        = "EC2Access"
          effect     = "Allow"
          actions    = ["ec2:*", "ElasticLoadBalancing:*"]
          resources  = ["*"]
          conditions = []
        }
      ]
    }
  }
}

locals {
  codepipelines = {
    "${local.parameter}-pipeline" = {
      tags = {Name = "${local.parameter}-pipeline"}

      pipeline_type = "V2"

      bucket_name = "${local.parameter}-codepipeline-bucket"

      enable_source_github = true
      source_github_configuration = {
        owner      = local.github.user_name
        repo       = local.github.repository_name
        branch     = local.github.branch_name
        oauthtoken = local.github.access_token
      }

      enable_source_s3 = false
      source_s3_configuration = {
        bucket_name = "${local.parameter}-buckets"
        object_key = "source.zip"
        poll_for_source_changes = true
      }

      enable_build = true
      enable_codebuild = true
      codebuild_name = "${local.parameter}-build"

      enable_jenkins = false

      enable_approval = true

      enable_deploy = true
      enable_deploy_ec2 = true
      deploy_ec2_configuration = {
        application_name      = "${local.parameter}-app"
        deployment_group_name = "${local.parameter}-deploy"
      }

      enable_deploy_ecs = false
      deploy_ecs_configuration = {
        application_name                  = "${local.parameter}-ecs-app"
        deployment_group_name             = "${local.parameter}-ecs-deployment-group"
        appspec_template_path             = "appspec.yml"
        task_definition_template_path     = "taskdef.json"
      }

      enable_iam_role = true
      role_name   = "${local.parameter}-codepipeline-role"
      role_tags   = {Name = "${local.parameter}-codepipeline-role"}
      policy_name = "${local.parameter}-codepipeline-policy"
      policy_tags = {Name = "${local.parameter}-codepipeline-policy"}
      iam_role_arn = "arn:aws:iam::${data.aws_caller_identity.caller.account_id}:role/${local.parameter}-codepipeline-role"

      statements = [
        {
          sid        = "codepipeline"
          effect     = "Allow"
          actions    = ["kms:*", "codebuild:*", "codedeploy:*", "logs:*", "s3:*", "ec2:*", "ecs:*", "iam:PassRole"]
          resources  = ["*"]
          conditions = []
        }
      ]
    }
  }
}