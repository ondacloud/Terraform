variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "github_access_token" {
  type = string
}

variable "artifact_type" {
  type        = string
  default     = "CODEPIPELINE"
}

variable "enable_cache" {
  type = bool
}

variable "cache" {
  type = object({
    type = string
    location = string
    modes = string
  })
  default = null
}

variable "build_compute_type" {
  type = string
}

variable "build_image" {
  type = string
}

variable "build_image_pull_credentials_type" {
  type = string
}

variable "build_type" {
  type = string
}

variable "privileged_mode" {
  type = bool
}

variable "enable_environment_variable" {
  type = bool
  default = false
}

variable "environment_variables" {
  type = list(object(
    {
      name  = string
      value = string
    }
  ))
  default = null
}

variable "enable_vpc_config" {
  type = bool
  default = false
}

variable "vpc_config" {
  type = any
  default = {}
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

variable "enable_logs" {
  type = bool
  default = false
}

variable "logs_config" {
  type        = any
  default     = {}
}

variable "enable_file_system" {
  type = bool
  default = false
}

variable "file_system_locations" {
  type        = any
  default     = {}
}

variable "buildspec" {
  type = string
}

variable "source_type" {
  type = string
}

variable "source_location" {
  type = string
}

variable "report_build_status" {
  type = bool
}

variable "iam_role_name" {
  type = string
}

variable "role_tags" {
  type = map(string)
}

variable "iam_role_arn" {
  type = string
}

variable "statements" {
  type = list(object({
    sid        = optional(string, null)
    effect     = string
    actions    = list(string)
    resources  = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}

variable "enable_iam_role" {
  type = bool
}

variable "policy_name" {
  type    = string
}

variable "policy_tags" {
  type    = map(string)
}