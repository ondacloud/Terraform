variable "vpc_id" {
  type = string
}

variable "protect_subnet_ids" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "subnet_group_name" {
  type = string
}

variable "parameter_group_name" {
  type = string
}

variable "parameter_group_family" {
  type = string
}

variable "parameters" {
  type  = list(map(string))
  default = []
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "node_type" {
  type = string
}

variable "num_cache_nodes" {
  type = number
}

variable "port" {
  type = number
}

variable "az_mode" {
  type = string
}

variable "apply_immediately" {
  type = bool
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