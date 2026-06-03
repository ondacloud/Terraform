resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = var.vpc_tags
}

resource "aws_internet_gateway" "this" {
  count  = var.enable_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = local.types["public-0"].igw_tags
}


resource "aws_eip" "this" {
  for_each = {
    for k, v in local.types :
    k => v
    if v.type == "public" && var.enable_natgw
  }

  tags = {
    Name = "${each.key}-eip"
  }
}

resource "aws_nat_gateway" "this" {
  depends_on = [ aws_eip.this, aws_subnet.this, aws_internet_gateway.this ]

  for_each = {
    for k, v in local.types :
    k => v
    if v.type == "public" && var.enable_natgw
  }

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = aws_subnet.this[each.key].id

  tags = local.types["private-${substr(each.key, -1, 1)}"].natgw_tags
}

resource "aws_subnet" "this" {
  for_each = { for item in local.types : item.key => item }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.sn_cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.type == "public" ? true : false
  private_dns_hostname_type_on_launch = each.value.type == "workload" ? "resource-name" : null

  tags = each.value.sn_tags
}

resource "aws_route_table" "this" {
  for_each = local.rtbs_to_create

  vpc_id = aws_vpc.this.id

  tags = each.value.rtb_tags
}

resource "aws_route_table_association" "this" {
  depends_on = [ aws_subnet.this, aws_route_table.this ]

  for_each = { for k, v in local.types : k => v } 

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = contains(local.shared_rtb_types, each.value.type) ? aws_route_table.this[each.value.type].id : aws_route_table.this[each.key].id          
}

resource "aws_route" "this" {
  depends_on = [ aws_route_table.this, aws_internet_gateway.this, aws_nat_gateway.this ]

  for_each = {
    for k, v in local.rtbs_to_create :
    k => v
    if v.type == "public" || v.type == "private"
  }

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id     = each.value.type == "public"  ? aws_internet_gateway.this[0].id : null
  nat_gateway_id = each.value.type == "private" ? aws_nat_gateway.this["public-${substr(each.key, -1, 1)}"].id : null
}

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = var.default_rtb_tags
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  
  tags = var.default_sg_tags
}