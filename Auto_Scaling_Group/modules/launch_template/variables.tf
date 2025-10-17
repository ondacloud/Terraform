variable "vpc_id" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "instance_type" {
  type  = string
}

variable "userdata" {
  type  = string
}

variable "enable_monitoring" {
  type = bool
}

variable "block_device_mappings" {
  type = list(object({
    device_name = string
    ebs = optional(object({
      volume_size           = number
      volume_type           = string
      delete_on_termination = bool
      encrypted             = optional(bool)
      kms_key_id            = optional(string)
      snapshot_id           = optional(string)
      throughput            = optional(number)
      iops                  = optional(number)
    }))
    no_device    = optional(bool)
    virtual_name = optional(string)
  }))
}

variable "enable_create_keypair" {
  type        = bool
  default     = true
}

variable "keypair_name" {
  type = string
}

variable "keypair_file_path" {
  type  = string
}

variable "enable_create_iam_role" {
  type    = bool
}

variable "iam_role_name" {
  type  = string
}

variable "instance_profile_name" {
  type  = string
}

variable "iam_policies" {
  type  = list(string)
}

variable "tag_specifications" {
  type = list(object({
    resource_type = string
    tags = map(string)
  }))
}

variable "security_group_name" {
  type  = string
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