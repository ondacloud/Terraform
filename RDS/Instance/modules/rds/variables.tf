variable "vpc_id" {
  type = string
}

variable "protect_subnet_ids" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "class" {
  type = string
}

variable "storage_type" {
  type = string
}

variable "db_name" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "user_name" {
  type = string
}

variable "user_password" {
  type = string
}

variable "port" {
  type = number
}

variable "allocated_storage" {
  type = number
}

variable "skip_final_snapshot" {
  type = bool
}

variable "multi_az" {
  type = bool
}

variable "storage_encrypted" {
  type = bool
}

variable "publicly_accessible" {
  type = bool
}

variable "subnet_group_name" {
  type = string
}

variable "option_group_name" {
  type = string
}

variable "option_group_engine" {
  type = string
}

variable "option_group_engine_version" {
  type = string
}

variable "parameter_group_name" {
  type = string
}

variable "parameter_group_family" {
  type = string
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