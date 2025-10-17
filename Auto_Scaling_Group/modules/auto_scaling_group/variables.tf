variable "subnet_ids" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "tags" {
  type = list(object({
    key   = string
    value = string
  }))
}

variable "launch_template_id" {
  type = string
}

variable "tags_no_launch" {
  type = bool
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "health_check_type" {
  type = string
}

variable "health_check_grace_period" {
  type = number
}

variable "timeout_delete_time" {
  type = string
}

variable "enable_attach_elb" {
  type = bool
}

variable "elb_target_group_arn" {
  type = string
  default = ""
}

variable "enable_scaling_policy" {
  type = bool
}

variable "scaling_policys" {
  type = list(object({
    name                         = string
    policy_type                  = string
    target_tracking_configuration = object({
      predefined_metric_specification = object({
        predefined_metric_type = string
      })
      target_value     = number
      disable_scale_in = bool
    })
  }))
}

variable "elb_arn_suffix" {
  type = string
  default = ""
}

variable "elb_target_group_arn_suffix" {
  type = string
  default = ""
}