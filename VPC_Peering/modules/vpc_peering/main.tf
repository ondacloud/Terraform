resource "aws_vpc_peering_connection" "this" {
  peer_vpc_id   = var.requestor.vpc_id
  vpc_id        = var.accepter.vpc_id

  auto_accept = var.auto_accept

  requester {
    allow_remote_vpc_dns_resolution = var.requestor.allow_remote_vpc_dns_resolution
  }

  accepter {
    allow_remote_vpc_dns_resolution = var.accepter.allow_remote_vpc_dns_resolution
  }

  tags = var.tags
}

resource "aws_route" "requestor" {
  depends_on = [aws_vpc_peering_connection.this]

  for_each = {for idx, rt_id in var.requestor.route_table_ids : idx => rt_id}
  
  route_table_id            = each.value
  destination_cidr_block    = var.accepter.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "accepter" {
  depends_on = [aws_vpc_peering_connection.this]

  for_each = {for idx, rt_id in var.accepter.route_table_ids : idx => rt_id}

  route_table_id            = each.value
  destination_cidr_block    = var.requestor.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}