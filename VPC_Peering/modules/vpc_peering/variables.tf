variable "tags" {
  type = map(string)
}

variable "auto_accept" {
  type = bool
  default = true
}

variable "requestor" {
  type = object({
    vpc_id = string
    vpc_cidr = string
    route_table_ids = list(string)
    allow_remote_vpc_dns_resolution = bool
  })
}

variable "accepter" {
  type = object({
    vpc_id = string
    vpc_cidr = string
    route_table_ids = list(string)
    allow_remote_vpc_dns_resolution = bool
  })
}