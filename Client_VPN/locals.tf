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
      default_sg_tags  = {Name = "${local.parameter}-default-sg"}

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
  cloudwatch_logs = {
    "/${local.parameter}/client-vpn/log" = {
      tags = {Name = "/${local.parameter}/client-vpn/log"}

      enable_kms = false
      kms_key_name = "${local.parameter}/kms/cw"

      retention_in_days = 7

      create_log_stream = true
      log_stream_names = ["/${local.parameter}/client-vpn/stream"]
    },
  }
}


locals {
  client_vpns = {
    "${local.parameter}-client-vpn" = {
      tags = {Name = "${local.parameter}-client-vpn"}

      vpc_name = "${local.parameter}-vpc"

      targets = [
        {subnet_name = "${local.parameter}-private-a", destination_cidr_block = "0.0.0.0/0"},
        {subnet_name = "${local.parameter}-private-c", destination_cidr_block = "0.0.0.0/0"},
      ]

      create_certificates = true
      certificate_file_path = "${path.cwd}/certificates/"

      algorithm = "RSA"
      rsa_bits = 2048 # 4096

      certificate = {
        ca = {
          common_name  = "${local.parameter}-ca"
          organization = null
          dns_names = ["${local.parameter}.local"]
          validity_period_hours = 8760
          is_ca_certificate = true
        }

        server = {
          common_name = "${local.parameter}-server"
          organization = null
          dns_names = ["${local.parameter}.local"]
          validity_period_hours = 8760
        }

        client = {
          common_name = "${local.parameter}-client"
          organization = null
          dns_names = ["${local.parameter}.local"]
          validity_period_hours = 8760
        }
      }

      client_cidr_block = "192.168.0.0/22"
      vpn_port = 443 # 1194
      split_tunnel = true
      self_service_portal = false
      dns_servers = []
      session_timeout_hours = 24
      disconnect_on_session_timeout = false
      enable_vpn_route = false
      target_network_cidr = "0.0.0.0/0"
      authentication_type = "certificate-authentication"
      authorize_all_groups = true

      enable_client_login_banner = false
      client_login_banner_text = "Welcome to the ${local.parameter} Client VPN!"

      enable_connection_logging = true
      cloudwatch_log_group_name = "/${local.parameter}/client-vpn/log"
      cloudwatch_log_stream_name = "/${local.parameter}/client-vpn/stream"

      security_group_name = "${local.parameter}-client-vpn-sg"
      security_group_tags = {Name = "${local.parameter}-client-vpn-sg"}
      ingress_ports = [{from_port = 443, to_port = 443, protocol = "udp", cidr_block = "0.0.0.0/0"}]
      egress_ports = [{from_port = 0, to_port = 0, protocol = "-1", cidr_block = "0.0.0.0/0"}]
    }
  }
}