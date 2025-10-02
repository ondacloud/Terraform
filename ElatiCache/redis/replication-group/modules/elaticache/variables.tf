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

variable "node_type" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "port" {
  type = number
}

variable "automatic_failover_enabled" {
  type = bool
}

variable "num_node_groups" {
  type = number
}

variable "replicas_per_node_group" {
  type = number
}

variable "multi_az_enabled" {
  type = bool
}

variable "at_rest_encryption_enabled" {
  type = bool
}

variable "transit_encryption_enabled" {
  type = bool
}

variable "transit_encryption_mode" {
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