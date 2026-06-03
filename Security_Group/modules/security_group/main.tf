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
