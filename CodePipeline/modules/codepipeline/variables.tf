variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "codebuild_name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "pipeline_type" {
  type = string
}

variable "enable_source_github" {
  type = bool
}

variable "source_github_configuration" {
  type = object({
    owner      = string
    repo       = string
    branch     = string
    oauthtoken = string
  })
}

variable "enable_source_s3" {
  type = bool
}

variable "source_s3_configuration" {
  type = object({
    bucket_name             = string
    object_key           = string
    poll_for_source_changes = bool
  })
}

variable "enable_build" {
  type = bool
}

variable "enable_codebuild" {
  type = bool
}

variable "enable_approval" {
  type = bool
}

variable "enable_deploy" {
  type = bool
}

variable "enable_deploy_ec2" {
  type = bool
}

variable "deploy_ec2_configuration" {
  type = object({
    application_name     = string
    deployment_group_name = string
  })
}

variable "enable_deploy_ecs" {
  type = bool
}

variable "deploy_ecs_configuration" {
  type = object({
    application_name                   = string
    deployment_group_name              = string
    appspec_template_path              = string
    task_definition_template_path      = string
  })
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