variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "performance_mode" {
  type = string
}

variable "encrypted" {
  type = bool
  default = false
}

variable "kms_key_id" {
  type = string
  default = null
}

variable "provisioned_throughput_in_mibps" {
  type = string
}

variable "throughput_mode" {
  type = string
}

variable "enable_backup_policy" {
  type = bool
  default = false
}

variable "security_group_name" {
  type  = string
}

variable "security_group_tags" {
  type = map(string)
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