variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "route_table_ids" {
  type = list(string)
}

variable "service_name" {
  type = string
}

variable "endpoint_type" {
  type = string
}

variable "enable_private_dns" {
  type = bool
  default = true
}

variable "security_group_id" {
  type = string
}

variable "tags" {
  type = map(string)
}