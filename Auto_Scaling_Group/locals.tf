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
  launch_templates = {
    "${local.parameter}-app-lt" = {
      vpc_name = "${local.parameter}-vpc"
      tags = {
        Name = "${local.parameter}-app-lt"
      }

      enable_monitoring = true

      instance_type = "t2.micro"
      userdata      = "/asg/userdata.sh"

      block_device_mappings = [
        {
          device_name = "/dev/xvda" # /dev/sdh or /dev/xvda
          ebs = {
            volume_size           = 10
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      ]

      tag_specifications = [
        {
          resource_type = "instance"
          tags = {
            Name = "${local.parameter}-app-instance"
          }
        }
      ]

      security_group_name = "${local.parameter}-asg-sg"

      ingress_ports = [
        { from_port = 22, to_port = 22, protocol = "tcp", cidr_block = "0.0.0.0/0"},
        { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0"},
      ]

      egress_ports = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"},
        # { from_port = 22, to_port = 22, protocol = "tcp", cidr_block = "0.0.0.0/0"},
        # { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0"},
        # { from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "0.0.0.0/0"}
      ]
      
      enable_create_keypair = false
      keypair_name          = "${local.parameter}"
      keypair_file_path     = "${path.cwd}/${local.parameter}.pem"

      enable_create_iam_role = false
      iam_role_name         = "${local.parameter}-asg-role"
      instance_profile_name = "${local.parameter}-asg-profile"
      iam_policies          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
  }
}

locals {
  asgs = {
    "${local.parameter}-app-asg" = {
      vpc_name                 = "${local.parameter}-vpc"
      internal                 = true

      tags = {
        Name = "${local.parameter}-app-asg"
      }
      tags_no_launch            = false

      desired_capacity          = 2
      min_size                  = 1
      max_size                  = 10

      desired_capacity_type     = "units"
      health_check_type         = "ELB" # EC2
      health_check_grace_period = 300
      timeout_delete_time       = "10m"

      tags = [
        {
          key   = "Name"
          value = "${local.parameter}-app-asg"
        },
      ]

      launch_template_name       = "${local.parameter}-app-lt"
      
      enable_attach_elb          = false
      elb_name                   = "${local.parameter}-alb"
      elb_target_group_name      = "${local.parameter}-alb-tg"
      
      enable_scaling_policy      = false
      scaling_policys = [
        {
          name = "${local.parameter}-cpu-target-policy"
          policy_type = "TargetTrackingScaling"
          target_tracking_configuration = {
            predefined_metric_specification = {
              predefined_metric_type = "ASGAverageCPUUtilization"
            }
            target_value       = 50.0
            disable_scale_in   = false
          }
        },
        {
          name = "${local.parameter}-alb-request-policy"
          policy_type = "TargetTrackingScaling"
          target_tracking_configuration = {
            predefined_metric_specification = {
              predefined_metric_type = "ALBRequestCountPerTarget"
            }
            target_value       = 50.0
            disable_scale_in   = false
          }
        },
      ]
    },
  }
}