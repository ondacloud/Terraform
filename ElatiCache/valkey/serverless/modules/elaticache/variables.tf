variable "vpc_id" {
  type = string
}

variable "protect_subnet_ids" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "data_storage" {
  type = object({
    minimum = number
    maximum = number
    unit    = string
  })
}

variable "ecpu_per_second" {
  type = object({
    minimum = number
    maximum = number
  })
}

variable "security_group_name" {
  type = string
}

variable "ingress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
  }))
}

variable "egress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
  }))
}