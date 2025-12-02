variable "cluster_name" {
  type = string
}

variable "cluster_tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal" {
  type = bool
}

variable "cluster_container_insights" {
  type = string
}

variable "enable_load_balancers" {
  type = bool
  default = false
}

variable "taskdefinition" {
  type = map(any)
}

variable "service" {
  type = map(any)
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

variable "enable_create_iam_role" {
  type    = bool
}

variable "iam_task_role_name" {
  type  = string
}

variable "iam_task_policies" {
  type  = list(string)
}

variable "iam_task_role_tags" {
  type = map(string)
}

variable "iam_exec_role_name" {
  type = string
}

variable "iam_exec_role_tags" {
  type = map(string)
}

variable "iam_exec_policies" {
  type = list(string)
}

variable "enable_secrets_manager" {
  type    = bool
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

variable "iam_exec_policy_name" {
  type = string
}

variable "iam_exec_policy_tags" {
  type = map(string)
}

variable "iam_ec2_role_name" {
  type = string
}

variable "iam_ec2_role_tags" {
  type = map(string)
}

variable "iam_ec2_policies" {
  type = list(string)
}

variable "instance_profile_name" {
  type  = string
}

variable "log_image_uri" {
  type = string
  default = null
}

variable "app_ecr_url" {
  type = map(string)
  default = null
}

variable "log_ecr_url" {
  type = map(string)
  default = null
}

variable "opensearch_host" {
  type = string
}

variable "secrets_manager_arn" {
  type = map(string)
  default = {}
}

variable "containers" {
  type        = map(any)
  default     = null
}

variable "target_group_arns" {
  type = map(string)
  default = {}
}