variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}
variable "name" {
  type  = string
}

variable "instance_tags" {
  type = map(string)
}

variable "instance_type" {
  type  = string
}

variable "userdata" {
  type  = string
}

variable "enable_public_ip" {
  type = bool
}

variable "enable_eip" {
  type    = bool
}

variable "eip_tags" {
  type = map(string)
}

variable "root_block_device" {
  type = object({
    volume_size = number
    volume_type = string
    delete_on_termination = bool
  })
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