variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "handler" {
  type = string
}

variable "timeout" {
  type = number
}

variable "runtime" {
  type = string
}

variable "publish" {
  type = bool
}

variable "enable_lambda_edge" {
  type = bool
}

variable "enable_upload_zip" {
  type = bool
}

variable "iam_role_name" {
  type  = string
}

variable "iam_role_tags" {
  type = map(string)
}

variable "iam_policies" {
  type  = list(string)
}

variable "source_file_path" {
  type = string
}

variable "output_file_path" {
  type = string
}

variable "enable_vpc_config" {
  type = bool
  default = false
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
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