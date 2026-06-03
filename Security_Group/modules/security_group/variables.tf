variable "vpc_id" {
  type = string
}

variable "security_group_name" {
  type  = string
}

variable "security_group_tags" {
  type = map(string)
}

variable "ingress_ports" {
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_block       = optional(string)
    prefix_list_id   = optional(string)
    security_groups = optional(list(string))
  }))
}

variable "egress_ports" {
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_block       = optional(string)
    prefix_list_id   = optional(string)
    security_groups = optional(list(string))
  }))
}