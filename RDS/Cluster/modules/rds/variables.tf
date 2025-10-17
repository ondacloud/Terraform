variable "vpc_id" {
  type = string
}

variable "protect_subnet_ids" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "rds_cluster_tags" {
  type = map(string)
}

variable "instance_name" {
  type = string
}

variable "instance_tags" {
  type = map(string)
}

variable "db_name" {
  type = string
}

variable "cw_logs_exports" {
  type = list(string)
}

variable "engine" {
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

variable "backtrack_window" {
  type = number
}

variable "skip_final_snapshot" {
  type = bool
}

variable "storage_encrypted" {
  type = bool
}

variable "performance_insights_enabled" {
  type = bool
}

variable "instance_count" {
  type = number
}

variable "instance_class" {
  type = string
}

variable "instance_engine" {
  type = string
}

variable "subnet_group_name" {
  type = string
}

variable "subnet_group_tags" {
  type = map(string)
}

variable "cluster_parameter_group_name" {
  type = string
}

variable "cluster_parameter_group_family" {
  type = string
}

variable "parameters" {
  type  = list(map(string))
  default = []
}

variable "cluster_parameter_group_tags" {
  type = map(string)
}

variable "parameter_group_name" {
  type = string
}

variable "parameter_group_family" {
  type = string
}

variable "parameter_group_tags" {
  type = map(string)
}

variable "security_group_name" {
  type = string
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