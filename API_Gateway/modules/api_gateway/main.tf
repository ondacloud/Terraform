resource "aws_iam_role" "this" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["apigateway.amazonaws.com"]
        }
      }
    ]
  })

  tags = var.iam_role_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = toset(var.iam_policies)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_lambda_permission" "this" {
  count = var.enable_lambda ? 1 : 0

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = var.lambda_name

  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

resource "aws_api_gateway_rest_api" "this" {
  name = var.name

  tags = var.tags
}

resource "aws_api_gateway_usage_plan" "this" {
  count = var.enable_api_key ? 1 : 0

  name = var.usage_plan_name

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  dynamic "throttle_settings" {
    for_each = var.enable_throttle_settings ? [1] : []
    content {
      rate_limit  = var.rate_limit
      burst_limit = var.burst_limit
    }
  }

  tags = var.usage_plan_tags
}

resource "aws_api_gateway_api_key" "this" {
  count = var.enable_api_key ? 1 : 0
  name  = var.api_key_name

  tags = var.api_key_tags
}

resource "aws_api_gateway_usage_plan_key" "this" {
  count = var.enable_api_key ? 1 : 0

  key_id        = aws_api_gateway_api_key.this[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[0].id
}

resource "aws_api_gateway_resource" "root" {
  for_each = { for k, v in local.api_resources : k => v if v.root_resource }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path_part
}

resource "aws_api_gateway_resource" "child" {
  for_each = { for k, v in local.api_resources : k => v if !v.root_resource }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.root[each.value.parent_resource].id
  path_part   = each.value.path_part
}

resource "aws_api_gateway_request_validator" "this" {
  for_each = { for k, v in local.api_methods : k => v if try(v.request_validator, false)}

  name                        = each.value.validate_name
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = each.value.validate_request_body
  validate_request_parameters = each.value.validate_request_parameters
}

resource "aws_api_gateway_method" "this" {
  for_each = local.api_methods

  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = contains(keys(aws_api_gateway_resource.root), each.value.resource_key) ? aws_api_gateway_resource.root[each.value.resource_key].id : aws_api_gateway_resource.child[each.value.resource_key].id
  authorization        = each.value.authorization
  http_method          = each.value.http_method
  request_validator_id = contains(keys(aws_api_gateway_request_validator.this), each.key) ? aws_api_gateway_request_validator.this[each.key].id : null
  request_models       = each.value.request_models
  request_parameters   = each.value.request_parameters
  api_key_required     = var.enable_api_key && each.value.enable_api_key ? true : false
}

resource "aws_api_gateway_integration" "this" {
  for_each = local.api_methods

  rest_api_id             = aws_api_gateway_rest_api.this.id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  resource_id             = contains(keys(aws_api_gateway_resource.root), each.value.resource_key) ? aws_api_gateway_resource.root[each.value.resource_key].id : aws_api_gateway_resource.child[each.value.resource_key].id
  integration_http_method = "POST"
  type                    = each.value.type
  uri                     = each.value.type == "AWS_PROXY" || each.value.type == "AWS" ? var.lambda_invoke_arn : var.service_arn
  credentials             = each.value.type == "AWS_PROXY" || each.value.type == "MOCK" || each.value.type == "AWS" ? null : aws_iam_role.this.arn

  request_templates = each.value.use_request_templates ? {
    for content_type, template_path in each.value.request_templates :
    content_type => file("${path.module}/../../src${template_path}")
  } : null
}

resource "aws_api_gateway_integration_response" "this" {
  depends_on = [aws_api_gateway_integration.this]

  for_each = local.api_routes_with_response_mappings

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = contains(keys(aws_api_gateway_resource.root), each.value.resource_key) ? aws_api_gateway_resource.root[each.value.resource_key].id : aws_api_gateway_resource.child[each.value.resource_key].id
  http_method = aws_api_gateway_method.this[each.key].http_method
  status_code = each.value.status_code

  response_templates = each.value.use_response_templates ? {
    for content_type, template_path in each.value.response_templates :
    content_type => file("${path.module}/../../src${template_path}")
  } : null
}

resource "aws_api_gateway_method_response" "this" {
  for_each = local.api_routes_with_response_mappings

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = contains(keys(aws_api_gateway_resource.root), each.value.resource_key) ? aws_api_gateway_resource.root[each.value.resource_key].id : aws_api_gateway_resource.child[each.value.resource_key].id
  http_method = aws_api_gateway_method.this[each.key].http_method
  status_code = each.value.status_code

  response_models = each.value.use_response_models ? each.value.response_models : null
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [aws_api_gateway_integration.this, aws_api_gateway_method.this]

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(var.api_maps))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  depends_on = [aws_api_gateway_rest_api.this, aws_api_gateway_deployment.this]

  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
}