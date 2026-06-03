variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "fifo_queue" {
  type = bool
  default = false
}

variable "content_based_deduplication" {
  type = bool
  default = false
}

variable "deduplication_scope" {
  type = string
}

variable "delay_seconds" {
  type = number
}

variable "fifo_throughput_limit" {
  type = string
}

variable "enable_kms" {
  type = bool
  default = false
}

variable "kms_data_key_reuse_period_seconds" {
  type = number
}

variable "kms_key_id" {
  type = string
}

variable "max_message_size" {
  type = number
}

variable "message_retention_seconds" {
  type = number
}

variable "receive_wait_time_seconds" {
  type = number
}

variable "sqs_managed_sse_enabled" {
  type = bool
  default = false
}

variable "visibility_timeout_seconds" {
  type = number
}