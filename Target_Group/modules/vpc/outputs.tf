output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = [
    for k, s in aws_subnet.this :
    s.id if lookup(local.types[k], "type", "") == "public"
  ]
}

output "private_subnet_ids" {
  value = [
    for k, s in aws_subnet.this :
    s.id if lookup(local.types[k], "type", "") == "private"
  ]
}

output "protect_subnet_ids" {
  value = [
    for k, s in aws_subnet.this :
    s.id if lookup(local.types[k], "type", "") == "protect"
  ]
}

output "inspect_subnet_ids" {
  value = [
    for k, s in aws_subnet.this :
    s.id if lookup(local.types[k], "type", "") == "inspect"
  ]
}

output "public_route_table_ids" {
  value = [
    for k, rt in aws_route_table.this :
    rt.id if lookup(local.rtbs_to_create[k], "type", "") == "public"
  ]
}

output "protect_route_table_ids" {
  value = [
    for k, rt in aws_route_table.this :
    rt.id if lookup(local.rtbs_to_create[k], "type", "") == "protect"
  ]
}

output "private_route_table_ids" {
  value = [
    for k, rt in aws_route_table.this :
    rt.id if lookup(local.rtbs_to_create[k], "type", "") == "private"
  ]
}

output "inspect_route_table_ids" {
  value = [
    for k, rt in aws_route_table.this :
    rt.id if lookup(local.rtbs_to_create[k], "type", "") == "inspect"
  ]
}


output "igw_id" {
  value = var.enable_igw ? aws_internet_gateway.this[0].id : null
}

output "natgw_ids" {
  value = values(try({ for k, ngw in aws_nat_gateway.this : k => ngw.id }, {}))
}

output "public_subnet_azs" {
  value = values(try({ for k, s in aws_subnet.this : k => s.availability_zone if s.type == "public" }, {}))
}

output "private_subnet_azs" {
  value = values(try({ for k, s in aws_subnet.this : k => s.availability_zone if s.type == "private" }, {}))
}

output "protect_subnet_azs" {
  value = values(try({ for k, s in aws_subnet.this : k => s.availability_zone if s.type == "protect" }, {}))
}

output "inspect_subnet_azs" {
  value = values(try({ for k, s in aws_subnet.this : k => s.availability_zone if s.type == "inspect" }, {}))
}

output "subnet_ids" {
  value = {
    for k, sn in aws_subnet.this :
    "${sn.tags["Name"]}" => sn.id
  }
}

output "subnet_ids_by_type" {
  value = {
    for t in distinct([for v in local.types : v.type]) :
    t => [
      for k, s in aws_subnet.this :
      s.id if local.types[k].type == t
    ]
  }
}

output "route_table_ids_by_type" {
  value = {
    for t in distinct([for v in local.types : v.type]) :
    t => [
      for k, rt in aws_route_table.this :
      rt.id if local.rtbs_to_create[k].type == t
    ]
  }
}