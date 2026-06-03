variable "app_name" {
  type = string
}

variable "app_tags" {
  type = map(string)
}

variable "deployment_config_name" {
  type = string
}

variable "deployment_group_name" {
  type = string
}

variable "deployment_group_tags" {
  type = map(string)
}

variable "compute_platform" {
  type = string
}

variable "minimum_healthy_hosts" {
  type = object({
    type  = string
    value = number
  })
}

variable "traffic_routing_config" {
  type = object({
    type       = string
    interval   = optional(number)
    percentage = optional(number)
  })
  default = null
}

variable "outpdated_instances_strategy" {
  type = string
}

variable "auto_rollback_configuration_enabled" {
  type = bool
}

variable "auto_rollback_configuration_events" {
  type = string
}

variable "deployment_style" {
  type = object({
    deployment_option = string
    deployment_type   = string
  })
}

variable "blue_green_deployment_config" {
  type = object({
    deployment_ready_option = optional(object({
      action_on_timeout    = string
      wait_time_in_minutes = number
    }))
    green_fleet_provisioning_option = optional(object({
      action = string
    }))
    terminate_blue_instances_on_deployment_success = optional(object({
      action                       = string
      termination_wait_time_in_minutes = number
    }))
  })
  default = null
}

variable "ec2_tag_set" {
  type = list(object({
    ec2_tag_filter = list(object({
      key   = string
      type  = string
      value = string
    }))
  }))
}

variable "ecs_service" {
  type = list(object({
    cluster_name = string
    service_name = string
  }))
  default = []
}

variable "load_balancer_info" {
  type    = any
  default = null
}

variable "iam_role_name" {
  type = string
}

variable "iam_role_tags" {
  type = map(string)
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

variable "iam_policy_name" {
  type    = string
}
  
variable "iam_policy_tags" {
  type    = map(string)
}