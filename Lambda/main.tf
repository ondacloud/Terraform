module "lambda" {
  source = "./modules/lambda"

  for_each = local.lambdas

  name               = each.key
  tags               = each.value.tags
  handler            = each.value.handler
  timeout            = each.value.timeout
  runtime            = each.value.runtime
  source_file_path   = each.value.source_file_path
  output_file_path   = each.value.output_file_path
  publish            = each.value.publish
  
  enable_lambda_edge = each.value.enable_lambda_edge
  enable_upload_zip  = each.value.enable_upload_zip
  
  iam_role_name      = each.value.iam_role_name
  iam_role_tags      = each.value.iam_role_tags
  iam_policies       = each.value.iam_policies
}