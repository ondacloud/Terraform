module "vpc" {
  source = "./modules/vpc"

  for_each = local.vpcs

  az_override      = local.az_override
  azs              = local.azs
  enable_igw       = each.value.enable_igw
  enable_natgw     = each.value.enable_natgw

  default_rtb_tags = each.value.default_rtb_tags
  default_sg_tags  = each.value.default_sg_tags
  vpc_name         = each.key
  vpc_cidr         = each.value.vpc_cidr
  vpc_tags         = each.value.vpc_tags
  types            = each.value.types
}

module "cloudwatch_logs" {
  source = "./modules/cloudwatch_logs"

  for_each = local.cloudwatch_logs

  name       = each.key
  tags       = each.value.tags
  # kms_key_id = each.value.enable_kms ? module.kms[each.value.kms_key_name].kms_arn : null
  kms_key_id = null

  create_log_stream = each.value.create_log_stream
  log_stream_names = each.value.log_stream_names
}

module "client_vpn" {
  depends_on = [module.vpc, module.cloudwatch_logs]
  
  source = "./modules/client_vpn"

  for_each = local.client_vpns

  vpc_id                        = module.vpc[each.value.vpc_name].vpc_id
  targets                       = {for t in each.value.targets : t.subnet_name => {
      subnet_id                 = module.vpc[each.value.vpc_name].subnet_ids[t.subnet_name]
      destination_cidr_block    = t.destination_cidr_block
    }
  }

  tags                          = each.value.tags

  create_certificates           = each.value.create_certificates
  certificate_file_path         = each.value.certificate_file_path
  algorithm                     = each.value.algorithm
  rsa_bits                      = each.value.rsa_bits
  certificate                   = each.value.certificate

  client_cidr_block             = each.value.client_cidr_block
  vpn_port                      = each.value.vpn_port
  split_tunnel                  = each.value.split_tunnel
  self_service_portal           = each.value.self_service_portal
  dns_servers                   = each.value.dns_servers
  session_timeout_hours         = each.value.session_timeout_hours
  disconnect_on_session_timeout = each.value.disconnect_on_session_timeout
  enable_vpn_route              = each.value.enable_vpn_route
  target_network_cidr           = each.value.target_network_cidr
  authorize_all_groups          = each.value.authorize_all_groups
  authentication_type           = each.value.authentication_type

  enable_client_login_banner    = each.value.enable_client_login_banner
  client_login_banner_text      = each.value.client_login_banner_text

  enable_connection_logging     = each.value.enable_connection_logging
  cloudwatch_log_group_name     = each.value.enable_connection_logging ? module.cloudwatch_logs[each.value.cloudwatch_log_group_name].cw_log_group_name : null
  cloudwatch_log_stream_name    = each.value.enable_connection_logging ? module.cloudwatch_logs[each.value.cloudwatch_log_group_name].cw_log_stream_names[each.value.cloudwatch_log_stream_name] : null
  # cloudwatch_log_group_name     = null
  # cloudwatch_log_stream_name    = null

  security_group_name           = each.value.security_group_name
  security_group_tags           = each.value.security_group_tags
  ingress_ports                 = each.value.ingress_ports
  egress_ports                  = each.value.egress_ports
}