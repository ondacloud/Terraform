# https://stackoverflow.com/questions/61072514/terraform-how-to-create-a-api-gateway-post-method-at-root

resource "aws_api_gateway_rest_api" "apigw" {
    name = "<env>"
}

resource "aws_api_gateway_method" "GET" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  authorization = "NONE"
  http_method = "GET"
}

resource "aws_api_gateway_method" "POST" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  authorization = "NONE"
  http_method = "POST"
}

resource "aws_api_gateway_integration" "apigw_GET" {
    http_method = aws_api_gateway_method.GET.http_method
    resource_id = aws_api_gateway_rest_api.api.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.api.id
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "apigw_POST" {
    http_method = aws_api_gateway_method.POST.http_method
    resource_id = aws_api_gateway_rest_api.api.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.api.id
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

output "apigw" {
  value = aws_api_gateway_rest_api.apigw.arn
}