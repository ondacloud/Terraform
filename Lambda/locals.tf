locals {
  parameter = "demo"

  az_override  = ["a", "c"]

  azs = [
    for az in data.aws_availability_zones.az.names :
    az if contains(local.az_override, substr(az, -1, 1))
  ]
}

locals {
  lambdas = {
    "${local.parameter}-function" = {
      enable_lambda_edge = false
      enable_upload_zip  = false

      handler            = "lambda_function.lambda_handler"
      timeout            = 180
      runtime            = "python3.13"
      source_file_path   = "/lambda/lambda_function.py"
      output_file_path   = "/lambda/lambda_function_payload.zip"
      publish            = false

      iam_role_name      = "${local.parameter}-lambda-role"
      iam_policies       = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  }
}