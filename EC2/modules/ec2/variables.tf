variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}
variable "name" {
  type  = string
}

variable "security_group_name" {
  type  = string
}

variable "instance_type" {
  type  = string
}

variable "userdata" {
  type  = string
}

variable "enable_public_ip" {
  type = bool
  default = false
}

variable "enable_eip" {
  type    = bool
  default = false
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

variable "iam_role_name" {
  type  = string
}

variable "instance_profile_name" {
  type  = string
}

variable "iam_policies" {
  type  = list(string)
}