resource "aws_iam_role" "this" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = var.enable_lambda_edge ? ["lambda.amazonaws.com", "edgelambda.amazonaws.com"] : ["lambda.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = toset(var.iam_policies)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

data "archive_file" "this" {
  type        = "zip"
  source_file = "${path.module}/../../src${var.source_file_path}"
  output_path = "${path.module}/../../src${var.output_file_path}"
}

resource "aws_lambda_function" "this" {
  filename = data.archive_file.this.output_path
  function_name = var.name
  role = aws_iam_role.this.arn
  handler = var.handler
  timeout = var.timeout
  source_code_hash = var.enable_upload_zip ? filebase64sha256("${path.module}/../../src${var.output_file_path}") : data.archive_file.this.output_base64sha256 
  runtime = var.runtime
  publish = var.publish

  tags = var.tags
}