locals {
  parameter = "demo"
  hub_parameter = "${local.parameter}-hub"
  spoke_parameter = "${local.parameter}-spoke"

  az_override  = ["a", "c"]

  azs = [
    for az in data.aws_availability_zones.az.names :
    az if contains(local.az_override, substr(az, -1, 1))
  ]
}

locals {
  vpcs = {
    "${local.hub_parameter}-vpc" = {
      vpc_cidr         = "10.0.0.0/16"
      default_rtb_tags = {Name = "${local.hub_parameter}-default-rtb"}
      default_sg_tags  = {Name = "${local.hub_parameter}-default-sg"}

      vpc_tags = {Name = "${local.hub_parameter}-vpc"}

      enable_igw       = true
      enable_natgw     = false

      types = [
        {
          type         = "public"
          sn_cidrs     = ["10.0.0.0/24", "10.0.1.0/24"]
          sn_tags      = {Name = "${local.hub_parameter}-public-$1"}

          rtb_tags     = {Name = "${local.hub_parameter}-public-rtb"}

          igw_tags     = {Name = "${local.hub_parameter}-igw"}
        },
      ]
    },
    "${local.spoke_parameter}-vpc" = {
      vpc_cidr         = "192.168.0.0/16"
      default_rtb_tags = {Name = "${local.spoke_parameter}-default-rtb"}
      default_sg_tags  = {Name = "${local.spoke_parameter}-default-sg"}

      vpc_tags = {Name = "${local.spoke_parameter}-vpc"}

      enable_igw       = true
      enable_natgw     = true

      types = [
        {
          type         = "public"
          sn_cidrs     = ["192.168.0.0/24", "192.168.1.0/24"]
          sn_tags      = {Name = "${local.spoke_parameter}-public-$1"}

          rtb_tags     = {Name = "${local.spoke_parameter}-public-rtb"}

          igw_tags     = {Name = "${local.spoke_parameter}-igw"}
        },
        {
          type         = "private"
          sn_cidrs     = ["192.168.2.0/24", "192.168.3.0/24"]
          sn_tags      = {Name = "${local.spoke_parameter}-private-$1"}

          rtb_tags     = {Name = "${local.spoke_parameter}-private-rtb"}

          natgw_tags   = {Name = "${local.spoke_parameter}-natgw-$1"}
        },
      ]
    }
  }
}

locals {
  albs = {
    "${local.spoke_parameter}-alb" = {
      vpc_name              = "${local.spoke_parameter}-vpc"

      alb_tags              = { Name = "${local.spoke_parameter}-alb" }
      internal              = true
      port                  = 80
      protocol              = "HTTP"

      default_action = [
        {
          enabled = false
          type    = "forward"
          forward_config = {
            target_groups = [
              {name = "${local.spoke_parameter}-v1-tg", weight = 50},
              {name = "${local.spoke_parameter}-v2-tg", weight = 50},
            ]
          }
        },
        {
          enabled = true
          type    = "fixed-response"
          fixed_response_config = {
            content_type = "text/plain"
            status_code  = 404
            message_body = "Not Found"
          }
        }
      ]

      enable_listener_rules = true
      listener_rules = [
        {
          name = "block-healthcheck"
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
          name = "path-and-header-version1-forward"
          priority = 2
          condition = [
            {field = "path-pattern", values = ["/version"]},
            {field = "http-header", http_header_config = {name = "version", values = ["v1"]}}
          ]
          action = {
            type = "forward"
            config = {
              target_groups = [
                { name = "${local.spoke_parameter}-v1-tg", weight = 100 },
              ]
            }
          }
        },
        {
          name = "path-and-header-version2-forward"
          priority = 3
          condition = [
            {field = "path-pattern", values = ["/version"]},
            {field = "http-header", http_header_config = {name = "version", values = ["v2"]}}
          ]
          action = {
            type = "forward"
            config = {
              target_groups = [
                { name = "${local.spoke_parameter}-v2-tg", weight = 100 },
              ]
            }
          }
        },
        {
          name = "path-version-forward"
          priority = 4
          condition = [
            {field = "path-pattern", values = ["/version"]},
          ]
          action = {
            type = "forward"
            config = {
              target_groups = [
                { name = "${local.spoke_parameter}-v1-tg", weight = 50 },
                { name = "${local.spoke_parameter}-v2-tg", weight = 50 },
              ]
            }
          }
        }
      ]

      target_groups = [
        {
          name                 = "${local.spoke_parameter}-v1-tg"
          port                 = 80
          protocol             = "HTTP"
          target_type          = "instance"
          deregistration_delay  = 30
          tags                 = { Name = "${local.spoke_parameter}-v1-tg" }

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
        {
          name                 = "${local.spoke_parameter}-v2-tg"
          port                 = 80
          protocol             = "HTTP"
          target_type          = "instance"
          deregistration_delay  = 30
          tags                 = { Name = "${local.spoke_parameter}-v2-tg" }

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

      enable_attach_target      = true
      targets = [
        {
          type                  = "ec2"
          target_group_name     = "${local.spoke_parameter}-v1-tg"
          target_name           = "${local.spoke_parameter}-app-v1"
          target_port           = 80
        },
        {
          type                  = "ec2"
          target_group_name     = "${local.spoke_parameter}-v2-tg"
          target_name           = "${local.spoke_parameter}-app-v2"
          target_port           = 80
        }
      ]

      security_group_name = "${local.spoke_parameter}-alb-sg"
      security_group_tags = { Name = "${local.spoke_parameter}-alb-sg" }
      ingress_ports = [{ from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0" }]
      egress_ports   = [{ from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0" }]
    }
  }
}

locals {
  vpc_lattices = {
    "${local.parameter}-app-service" = {
      vpc_names                 = ["${local.hub_parameter}-vpc","${local.spoke_parameter}-vpc"]
      alb_name                  = "${local.spoke_parameter}-alb"

      service_network_name      = "${local.parameter}-app-service-network"
      service_network_auth_type = "NONE"
      service_network_tags      = {Name = "${local.parameter}-app-service-network"}
      service_network_vpc_tags  = {Name = "${local.parameter}-app-service-network-vpc-association"}

      service_name              = "${local.parameter}-app-service"
      service_auth_type         = "NONE"
      service_tags              = {Name = "${local.parameter}-app-service"}
      service_association_tags  = {Name = "${local.parameter}-service-association"}

      security_group_names       = ["${local.hub_parameter}-service-network-sg", "${local.spoke_parameter}-service-network-sg"]
      security_group_tags       = [{Name = "${local.hub_parameter}-service-network-sg"}, {Name = "${local.spoke_parameter}-service-network-sg"}]
      ingress_ports = [
        { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0" },
      ]
      egress_ports = [
        { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0" },
      ]

      target_groups = {
        "${local.spoke_parameter}-v1-tg" = {
          name = "${local.spoke_parameter}-v1-tg"
          type = "ALB"
          config = {
            port                           = 80
            protocol                       = "HTTP"
            vpc_identifier_name            = "${local.spoke_parameter}-vpc"
            ip_address_type                = null
            protocol_version               = null
            lambda_event_structure_version = null
          }
          health_check = {
            enabled                       = false
            health_check_interval_seconds = 5
            health_check_timeout_seconds  = 2
            healthy_threshold_count       = 2
            path                          = "/"
            port                          = 80
            protocol                      = "HTTP"
            protocol_version              = null
            unhealthy_threshold_count     = 2
            matcher                       = "200-399"
          }
          tags = { Name = "${local.spoke_parameter}-v1-tg" }
        }
        "${local.spoke_parameter}-v2-tg" = {
          name = "${local.spoke_parameter}-v2-tg"
          type = "ALB"
          config = {
            port                           = 80
            protocol                       = "HTTP"
            vpc_identifier_name            = "${local.spoke_parameter}-vpc"
            ip_address_type                = null
            protocol_version               = null
            lambda_event_structure_version = null
          }
          health_check = {
            enabled                       = false
            health_check_interval_seconds = 5
            health_check_timeout_seconds  = 2
            healthy_threshold_count       = 2
            path                          = "/"
            port                          = 80
            protocol                      = "HTTP"
            protocol_version              = null
            unhealthy_threshold_count     = 2
            matcher                       = "200-399"
          }
          tags = { Name = "${local.spoke_parameter}-v2-tg" }
        }
      }

      listener_name = "http"
      listener_protocol = "HTTP"
      listener_port = 80

      default_forward_target_groups = [
        {target_group_name = "${local.spoke_parameter}-v1-tg", weight = 50},
        {target_group_name = "${local.spoke_parameter}-v2-tg", weight = 50},
      ]

      listener_rules = [
        {
          name              = "version1"
          priority          = 1
          weight            = 100
          header_name       = "version"
          header_value      = "v1"
          target_group_name = "${local.spoke_parameter}-v1-tg"
        },
        {
          name              = "version2"
          priority          = 2
          weight            = 100
          header_name       = "version"
          header_value      = "v2"
          target_group_name = "${local.spoke_parameter}-v2-tg"
        }
      ]

      enable_attach_target = true
      targets = [
        {
          target_group_name = "${local.spoke_parameter}-v1-tg"
          target_name       = "${local.spoke_parameter}-alb"
          target_port       = 80
        },
        {
          target_group_name = "${local.spoke_parameter}-v2-tg"
          target_name       = "${local.spoke_parameter}-alb"
          target_port       = 80
        }
      ]
    }
  }
}