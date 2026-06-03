locals {
  parameter = "wsc-rest"
}

locals {
  api_gateways = {
    "${local.parameter}-api" = {
      tags = {Name = "${local.parameter}-api"}

      stage_name = "v1"

      enable_api_key = false
      api_key_name   = "${local.parameter}-api-key"
      api_key_tags   = {Name = "${local.parameter}-api-key"}

      usage_plan_name          = "${local.parameter}-usage-plan"
      usage_plan_tags          = {Name = "${local.parameter}-usage-plan"}
      enable_throttle_settings = false
      rate_limit               = 100
      burst_limit              = 200

      enable_lambda = true
      lambda_name   = "${local.parameter}-function"

      api_maps = {
        user_post = {
          resource_key                = "user"
          root_resource               = true
          parent_resource             = null
          request_validator           = true
          validate_name               = "${local.parameter}-user-post-validate-body"
          validate_request_body       = true
          validate_request_parameters = false
          path_part                   = "user"
          http_method                 = "POST"
          authorization               = "NONE"
          type                        = "AWS"
          status_code                 = 201
          use_request_templates       = true
          request_templates           = {"application/json" = "/api_gateway/user/post/request.vtl"}
          use_response_templates      = true
          response_templates          = {"application/json" = "/api_gateway/user/post/response.vtl"}
          request_models              = {"application/json" = "Empty"}
          request_parameters          = {}
          use_response_models         = true
          response_models             = {"application/json" = "Empty"}
          enable_api_key              = false
        }
        user_get = {
          resource_key                = "user"
          root_resource               = true
          parent_resource             = null
          request_validator           = true
          validate_name               = "${local.parameter}-user-get-validate-body"
          validate_request_body       = false
          validate_request_parameters = true
          request_validator           = true
          path_part                   = "user"
          http_method                 = "GET"
          authorization               = "NONE"
          type                        = "AWS"
          status_code                 = 200
          use_request_templates       = true
          request_templates           = {"application/json" = "/api_gateway/user/get/request.vtl"}
          use_response_templates      = true
          response_templates          = {"application/json" = "/api_gateway/user/get/response.vtl"}
          request_models              = {}
          request_parameters          = {"method.request.querystring.name" = true, "method.request.querystring.age" = true}
          use_response_models         = true
          response_models             = {"application/json" = "Empty"}
          enable_api_key              = false
        }
        healthcheck_get = {
          resource_key                = "healthcheck"
          root_resource               = true
          parent_resource             = null
          request_validator           = false
          validate_name               = "${local.parameter}-healthcheck-get-validate-body"
          validate_request_body       = false
          validate_request_parameters = false
          request_validator           = false
          path_part                   = "healthcheck"
          http_method                 = "GET"
          authorization               = "NONE"
          type                        = "MOCK"
          status_code                 = 200
          use_request_templates       = true
          request_templates           = {"application/json" = "/api_gateway/healthcheck/get/request.vtl"}
          use_response_templates      = true
          response_templates          = {"application/json" = "/api_gateway/healthcheck/get/response.vtl"}
          request_models              = {}
          request_parameters          = {}
          use_response_models         = true
          response_models             = {"application/json" = "Empty"}
          enable_api_key              = false
        }
      }

      iam_role_name = "${local.parameter}-api-gateway-role"
      iam_role_tags = { Name = "${local.parameter}-api-gateway-role" }
      iam_policies  = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
    }
  }
}