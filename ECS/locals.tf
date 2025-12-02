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
      ]
    }
  }
}

locals {
  albs = {
    "${local.parameter}-alb" = {
      vpc_name                = "${local.parameter}-vpc"

      alb_tags = {
        Name = "${local.parameter}-alb"
      }
      internal                  = false
      port                      = 80
      protocol                  = "HTTP"
      listener_target_groups    = ["${local.parameter}-alb-tg"]

      target_groups = [
        {
          name                  = "${local.parameter}-alb-tg"
          port                  = 80
          protocol              = "HTTP"
          target_type           = "ip" # instance or ip or lambda or alb
          deregistration_delay  = 30
          tags = {
            Name = "${local.parameter}-alb-tg"
          }

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
        }
      ]

      enable_attach_target      = false
      targets = [
        {
          type                  = "ec2"
          target_group_name     = "${local.parameter}-alb-tg"
          target_name           = "${local.parameter}-bastion"
          target_port           = 80
        },
      ]

      security_group_name     = "${local.parameter}-alb-sg"
      security_group_tags = {
        Name = "${local.parameter}-alb-sg"
      }

      ingress_ports = [
        { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
      ]
    }
  }
}

locals {
  ecrs = {
    "${local.parameter}-ecr" = {
      tags = {
        Name = "${local.parameter}-ecr"
      }

      image_tag_mutability              = "MUTABLE"
      force_delete                      = true
      scan_images_on_push               = false

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
  ecss = {
    "${local.parameter}-ecs-cluster" = {
      vpc_name                = "${local.parameter}-vpc"
      internal                = false

      cluster_tags = {
        Name = "${local.parameter}-ecs-cluster"
      }

      cluster_container_insights = "disabled" # enabled, enhanced
      enable_load_balancers      = true

      taskdefinition = {
        "${local.parameter}-taskdef" = {
          tags = {Name = "${local.parameter}-taskdef"}
          network_mode       = "awsvpc"
          cpu                = 512
          memory             = 1024
          enable_serverless  = true
        }
      }

      service = {
        "${local.parameter}-svc" = {
          tags = {Name = "${local.parameter}-service"}
          taskdefinition_name                = "${local.parameter}-taskdef"
          network_mode                       = "awsvpc"
          desired_count                      = 2
          health_check_grace_period_seconds  = 0
          deployment_maximum_percent         = 200
          deployment_minimum_healthy_percent = 100
          force_new_deployment               = true
          availability_zone_rebalancing      = "ENABLED"
          deployment_controller_type         = "ECS" # ECS, CODE_DEPLOY, EXTERNAL
          enable_serverless                  = true
          elb_name                           = "${local.parameter}-alb"
          
          load_balancers = [
            {
              target_group_name = "${local.parameter}-alb-tg"
              container_name    = "${local.parameter}-cnt"
              container_port    = 80
            },
          ]
        }
      }

      containers = {
        "${local.parameter}-taskdef" = {
          enable_awslogs                  = false
          enable_fluentbit                = false

          firelens_type                   = "cloudwatch_logs" # cloudwatch_logs or opensearch
          enable_fluentbit_file_type      = "file" # S3
          s3_bucket_path                  = "${local.parameter}-fluentbit-bucket"

          cloudwatch_log_group_name       = "/ecs/${local.parameter}-log-group"
          cloudwatch_log_stream_prefix    = "$${ECS_TASK_ID}"
          
          log_ecr_name                    = "${local.parameter}-ecr"
          log_ecr_tag                     = "latest"

          opensearch_name                 = "${local.parameter}-opensearch"
          opensearch_index                = "ecs-logs"

          enable_ecr                      = true
          name                            = "${local.parameter}-cnt"
          app_ecr_name                    = "${local.parameter}-ecr"
          app_image_tag                   = "latest"
          app_image                       = "tomcat:latest"
          essential                       = true
          cpu                             = 256
          memory                          = 512
          port_mappings = {container_port = 8080, host_port = 8080, protocol = "tcp"}
          health_check = {
            command       = ["CMD-SHELL", "curl -f http://localhost:8080/ || exit 1"]
            interval      = 30
            timeout       = 5
            retries       = 3
            start_period  = 0
          }
          enable_environment     = false
          environment            = {ENV_VAR_1 = "value1", ENV_VAR_2 = "value2"}

          enable_secrets_manager = false
          secrets_manager_name   = "${local.parameter}-db-secrets"
          secrets = [
            {name = "DB_USER", valueFrom = "DB_USER"},
            {name = "DB_PASSWORD", valueFrom = "DB_PASSWORD"},
            {name = "DB_URL", valueFrom = "DB_URL"}
          ]
        }
      }

      security_group_name = "${local.parameter}-ecs-sg"
      security_group_tags = {
        Name = "${local.parameter}-ecs-sg"
      }

      ingress_ports = [
        { from_port = 8080, to_port = 8080, protocol = "tcp", cidr_block = "0.0.0.0/0"},
        { from_port = 32768, to_port = 65535, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
      ]
      
      enable_create_keypair = true
      keypair_name           = "${local.parameter}"
      keypair_file_path      = "${path.cwd}/${local.parameter}.pem"

      enable_create_iam_role = true
      iam_task_role_name     = "${local.parameter}-ecs-task-role"
      iam_task_role_tags     = {Name = "${local.parameter}-ecs-task-role"}
      iam_task_policies      = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]

      iam_exec_role_name     = "${local.parameter}-ecs-exec-role"
      iam_exec_role_tag      = {Name = "${local.parameter}-ecs-exec-role"}
      iam_exec_policies      = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", "arn:aws:iam::aws:policy/CloudWatchFullAccess"]
      iam_exec_policy_name   = "${local.parameter}-secrets-policy"
      iam_exec_policy_tags   = {Name = "${local.parameter}-secrets-policy"}
      enable_secrets_manager = false
      statements = [
        {
          effect    = "Allow"
          actions   = ["secretsmanager:GetResourcePolicy", "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "secretsmanager:ListSecretVersionIds", "kms:Decrypt"]
          resources = ["*"]
          conditions = []
        }
      ]

      iam_ec2_role_name      = "${local.parameter}-ecs-ec2-role"
      iam_ec2_role_tags      = {Name = "${local.parameter}-ecs-ec2-role"}
      instance_profile_name  = "${local.parameter}-ecs-profile"
      iam_ec2_policies       = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]
    },
  }
}