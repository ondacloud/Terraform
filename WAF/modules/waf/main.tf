resource "aws_wafv2_web_acl" "this" {
  name  = var.name
  scope = var.enable_cloudfront ? "CLOUDFRONT" : "REGIONAL"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = local.managed_rules
    content {
      name     = rule.value.name
      priority = 10 + index(local.managed_rules, rule.value)

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.rule_group
          vendor_name = rule.value.vendor
        }
      }

      visibility_config {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.metric_name}-${rule.value.name}"
      }
    }
  }

  dynamic "rule" {
    for_each = local.custom_rules
    content {
      name     = rule.value.name
      priority = 100 + index(local.custom_rules, rule.value)

      dynamic "action" {
        for_each = rule.value.action == "allow" ? [1] : []
        content {
          allow {}
        }
      }

      dynamic "action" {
        for_each = rule.value.action == "block" ? [1] : []
        content {
          block {}
        }
      }

      dynamic "action" {
        for_each = rule.value.action == "count" ? [1] : []
        content {
          count {}
        }
      }

      statement {
        and_statement {
          statement {
            byte_match_statement {
              search_string         = upper(rule.value.method)
              positional_constraint = "EXACTLY"

              field_to_match {
                method {}
              }

              text_transformation {
                priority = 0
                type     = "NONE"
              }
            }
          }

          statement {
            dynamic "not_statement" {
              for_each = rule.value.negate ? [1] : []
              content {
                statement {
                  dynamic "or_statement" {
                    for_each = rule.value.operator == "or" ? [1] : []
                    content {
                      dynamic "statement" {
                        for_each = rule.value.matches
                        iterator = match_item
                        content {
                          byte_match_statement {
                            search_string         = lower(match_item.value)
                            positional_constraint = "CONTAINS"

                            dynamic "field_to_match" {
                              for_each = rule.value.field == "body" ? [1] : []
                              content {
                                body {
                                  oversize_handling = "CONTINUE"
                                }
                              }
                            }

                            dynamic "field_to_match" {
                              for_each = rule.value.field == "query_string" ? [1] : []
                              content {
                                query_string {}
                              }
                            }

                            text_transformation {
                              priority = 0
                              type     = "LOWERCASE"
                            }
                          }
                        }
                      }
                    }
                  }

                  dynamic "and_statement" {
                    for_each = rule.value.operator == "and" ? [1] : []
                    content {
                      dynamic "statement" {
                        for_each = rule.value.matches
                        iterator = match_item
                        content {
                          byte_match_statement {
                            search_string         = lower(match_item.value)
                            positional_constraint = "CONTAINS"

                            dynamic "field_to_match" {
                              for_each = rule.value.field == "body" ? [1] : []
                              content {
                                body {
                                  oversize_handling = "CONTINUE"
                                }
                              }
                            }

                            dynamic "field_to_match" {
                              for_each = rule.value.field == "query_string" ? [1] : []
                              content {
                                query_string {}
                              }
                            }

                            text_transformation {
                              priority = 0
                              type     = "LOWERCASE"
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }

            dynamic "or_statement" {
              for_each = !rule.value.negate && rule.value.operator == "or" ? [1] : []
              content {
                dynamic "statement" {
                  for_each = rule.value.matches
                  iterator = match_item
                  content {
                    byte_match_statement {
                      search_string         = lower(match_item.value)
                      positional_constraint = "CONTAINS"

                      dynamic "field_to_match" {
                        for_each = rule.value.field == "body" ? [1] : []
                        content {
                          body {
                            oversize_handling = "CONTINUE"
                          }
                        }
                      }

                      dynamic "field_to_match" {
                        for_each = rule.value.field == "query_string" ? [1] : []
                        content {
                          query_string {}
                        }
                      }

                      text_transformation {
                        priority = 0
                        type     = "LOWERCASE"
                      }
                    }
                  }
                }
              }
            }

            dynamic "and_statement" {
              for_each = !rule.value.negate && rule.value.operator == "and" ? [1] : []
              content {
                dynamic "statement" {
                  for_each = rule.value.matches
                  iterator = match_item
                  content {
                    byte_match_statement {
                      search_string         = lower(match_item.value)
                      positional_constraint = "CONTAINS"

                      dynamic "field_to_match" {
                        for_each = rule.value.field == "body" ? [1] : []
                        content {
                          body {
                            oversize_handling = "CONTINUE"
                          }
                        }
                      }

                      dynamic "field_to_match" {
                        for_each = rule.value.field == "query_string" ? [1] : []
                        content {
                          query_string {}
                        }
                      }

                      text_transformation {
                        priority = 0
                        type     = "LOWERCASE"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.metric_name}-${rule.value.name}"
      }
    }
  }

  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = var.metric_name
  }

  tags = var.tags
}

resource "aws_wafv2_web_acl_association" "this" {
  count = var.enable_cloudfront || var.alb_arn == null ? 0 : 1

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = length(var.log_destination_arns) > 0 ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = var.log_destination_arns
}