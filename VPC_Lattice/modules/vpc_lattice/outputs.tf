output "service_network_id" {
  value = aws_vpclattice_service_network.this.id
}

output "service_id" {
  value = aws_vpclattice_service.this.id
}

output "listener_id" {
  value = aws_vpclattice_listener.this.id
}

output "security_group_id" {
  value = { for k, v in aws_security_group.this : k => v.id }
}

output "target_group_ids" {
  value = { for k, v in aws_vpclattice_target_group.this : k => v.id }
}