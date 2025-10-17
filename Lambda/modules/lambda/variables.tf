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

variable "iam_policies" {
  type  = list(string)
}

variable "source_file_path" {
  type = string
}

variable "output_file_path" {
  type = string
}