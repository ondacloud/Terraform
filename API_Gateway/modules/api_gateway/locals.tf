locals {
  api_resources_grouped = {
    for route_key, route in var.api_maps :
    route.resource_key => route...
  }

  api_resources = {
    for resource_key, routes in local.api_resources_grouped :
    resource_key => routes[0]
  }

  api_methods = {
    for route_key, route in var.api_maps :
    route_key => route if route.http_method != null && route.http_method != ""
  }

  api_routes_with_response_mappings = {
    for route_key, route in var.api_maps :
    route_key => route if (route.use_response_templates || route.use_response_models) && route.http_method != null && route.http_method != ""
  }
}