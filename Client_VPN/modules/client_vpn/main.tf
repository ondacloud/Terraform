resource "aws_security_group" "this" {
  name   = var.security_group_name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      protocol  = ingress.value.protocol
      from_port = ingress.value.from_port
      to_port   = ingress.value.to_port

      cidr_blocks     = lookup(ingress.value, "cidr_block", null) != null ? [ingress.value.cidr_block] : null
      prefix_list_ids = lookup(ingress.value, "prefix_list_id", null) != null ? [ingress.value.prefix_list_id] : null
      security_groups = lookup(ingress.value, "security_groups", null)
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      protocol  = egress.value.protocol
      from_port = egress.value.from_port
      to_port   = egress.value.to_port

      cidr_blocks     = lookup(egress.value, "cidr_block", null) != null ? [egress.value.cidr_block] : null
      prefix_list_ids = lookup(egress.value, "prefix_list_id", null) != null ? [egress.value.prefix_list_id] : null
      security_groups = lookup(egress.value, "security_groups", null)
    }
  }

  tags = var.security_group_tags
}

resource "tls_private_key" "this" {
  for_each = var.create_certificates ? {for k, v in var.certificate : k => v if contains(["ca", "server", "client"], k)} : {}

  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

resource "tls_self_signed_cert" "this" {
  depends_on = [tls_private_key.this]

  for_each = var.create_certificates ? {for k, v in var.certificate : k => v if contains(["ca"], k)} : {}
  private_key_pem = tls_private_key.this[each.key].private_key_pem

  subject {
    common_name  = each.value.common_name
    organization = each.value.organization
  }

  dns_names = each.value.dns_names

  validity_period_hours = each.value.validity_period_hours
  early_renewal_hours   = 1
  is_ca_certificate     = each.value.is_ca_certificate

  allowed_uses = ["cert_signing", "crl_signing"]
}

resource "tls_cert_request" "this" {
  depends_on = [tls_private_key.this]

  for_each = var.create_certificates ? {for k, v in var.certificate : k => v if contains(["server", "client"], k)} : {}

  private_key_pem = tls_private_key.this[each.key].private_key_pem

  subject {
    common_name  = each.value.common_name
    organization = each.value.organization
  }

  dns_names = each.value.dns_names
}

resource "tls_locally_signed_cert" "this" {
  depends_on = [tls_self_signed_cert.this, tls_cert_request.this]

  for_each = var.create_certificates ? {for k, v in var.certificate : k => v if contains(["server", "client"], k)} : {}

  cert_request_pem      = tls_cert_request.this[each.key].cert_request_pem
  ca_private_key_pem    = tls_private_key.this["ca"].private_key_pem
  ca_cert_pem           = tls_self_signed_cert.this["ca"].cert_pem
  validity_period_hours = each.value.validity_period_hours
  early_renewal_hours   = 1

  allowed_uses = each.key == "server" ? ["key_encipherment", "digital_signature", "server_auth"] : ["key_encipherment", "digital_signature", "client_auth"]
}

resource "local_sensitive_file" "this" {
  depends_on = [tls_private_key.this]

  for_each = var.create_certificates ? { for k, v in var.certificate : k => v if contains(["ca", "server", "client"], k) } : {}

  content  = tls_private_key.this[each.key].private_key_pem
  filename = "${var.certificate_file_path}/${each.key}.key"
}

resource "local_file" "this" {
  depends_on = [tls_self_signed_cert.this, tls_locally_signed_cert.this]

  for_each = var.create_certificates ? { for k, v in var.certificate : k => v if contains(["ca", "server", "client"], k) } : {}

  content  = try(tls_self_signed_cert.this[each.key].cert_pem, tls_locally_signed_cert.this[each.key].cert_pem)
  filename = "${var.certificate_file_path}/${each.key}.crt"
}

resource "time_sleep" "wait_for_cert" {
  depends_on = [tls_private_key.this, tls_self_signed_cert.this, tls_locally_signed_cert.this]

  create_duration = "1m"
}

resource "aws_acm_certificate" "this" {
  depends_on = [tls_private_key.this, tls_self_signed_cert.this, tls_locally_signed_cert.this, time_sleep.wait_for_cert]

  for_each = var.create_certificates ? {for k, v in var.certificate : k => v if contains(["ca", "server", "client"], k)} : {}

  private_key       = tls_private_key.this[each.key].private_key_pem
  certificate_body  = each.key == "ca" ? tls_self_signed_cert.this[each.key].cert_pem : tls_locally_signed_cert.this[each.key].cert_pem
  certificate_chain = each.key == "ca" ? null : tls_self_signed_cert.this["ca"].cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  vpc_id                 = var.vpc_id
  client_cidr_block      = var.client_cidr_block
  vpn_port               = var.vpn_port
  split_tunnel           = var.split_tunnel
  self_service_portal    = var.self_service_portal ? "enabled" : "disabled"
  dns_servers            = var.dns_servers
  session_timeout_hours  = var.session_timeout_hours
  disconnect_on_session_timeout = var.disconnect_on_session_timeout 
  security_group_ids     = [aws_security_group.this.id]
  server_certificate_arn = aws_acm_certificate.this["server"].arn

  authentication_options {
    type                        = var.authentication_type
    root_certificate_chain_arn  = var.authentication_type == "certificate-authentication" ? aws_acm_certificate.this["ca"].arn : null
  }

  connection_log_options {
    enabled               = var.enable_connection_logging
    cloudwatch_log_group  = var.enable_connection_logging ? var.cloudwatch_log_group_name : null
    cloudwatch_log_stream = var.enable_connection_logging ? var.cloudwatch_log_stream_name : null
  }

  client_login_banner_options {
    enabled     = var.enable_client_login_banner
    banner_text = var.enable_client_login_banner ? var.client_login_banner_text : null
  }

  tags = var.tags
}

resource "aws_ec2_client_vpn_network_association" "this" {
  depends_on = [aws_ec2_client_vpn_endpoint.this]

  for_each = var.targets
  
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value.subnet_id
}

resource "aws_ec2_client_vpn_route" "this" {
  depends_on = [aws_ec2_client_vpn_endpoint.this, aws_ec2_client_vpn_network_association.this]

  for_each = var.enable_vpn_route ? var.targets : {}

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_vpc_subnet_id   = each.value.subnet_id
  destination_cidr_block = each.value.destination_cidr_block
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  depends_on = [aws_ec2_client_vpn_endpoint.this]

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.target_network_cidr
  authorize_all_groups   = var.authorize_all_groups
}

resource "local_file" "vpn_config" {
  depends_on = [tls_self_signed_cert.this, tls_locally_signed_cert.this, aws_ec2_client_vpn_endpoint.this, time_sleep.wait_for_cert]

  filename = "${var.certificate_file_path}/client-config.ovpn"
  content  = <<-EOF
client
dev tun
proto udp
remote ${replace(aws_ec2_client_vpn_endpoint.this.dns_name, "*.", "")} ${var.vpn_port}
remote-random-hostname
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
verb 3

<ca>
${tls_self_signed_cert.this["ca"].cert_pem}
</ca>

<cert>
${tls_locally_signed_cert.this["client"].cert_pem}
</cert>

<key>
${tls_private_key.this["client"].private_key_pem}
</key>

reneg-sec 0

verify-x509-name ${var.certificate.server.common_name} name
EOF
}