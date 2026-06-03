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

      enable_attach_target      = true
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