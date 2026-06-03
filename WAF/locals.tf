locals {
  parameter = "demo"
}

locals {
  wafs = {
    "${local.parameter}-waf" = {
      tags = {Name = "${local.parameter}-waf"}
      metric_name = "${local.parameter}-waf"

      enable_cloudfront = false
      alb_name = "${local.parameter}-alb"

      enable_logging = false
      cloudwatch_logs_group_name = "/${local.parameter}/waf/log"

      enable_managed = true
      managed_rules = [
        {
          enabled    = true
          name       = "AWSManagedRulesCommonRuleSet"
          vendor     = "AWS"
          rule_group = "AWSManagedRulesCommonRuleSet"
        },
        {
          enabled    = true
          name       = "AWSManagedRulesSQLiRuleSet"
          vendor     = "AWS"
          rule_group = "AWSManagedRulesSQLiRuleSet"
        },
        {
          enabled    = true
          name       = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor     = "AWS"
          rule_group = "AWSManagedRulesKnownBadInputsRuleSet"
        }
      ]

      enable_custom = true
      custom_rules = [
        {
          enabled  = true
          name     = "block-post-body-keywords"
          method   = "POST"
          field    = "body"
          matches  = ["admin", "sysop"]
          operator = "or" # and, or
          negate   = false
          action   = "block" # allow, block, count
        },
        {
          enabled  = true
          name     = "block-get-query-keywords"
          method   = "GET"
          field    = "query_string"
          matches  = ["admin", "sysop"]
          operator = "or" # and, or
          negate   = false
          action   = "block" # allow, block, count
        },
        {
          enabled  = true
          name     = "block-uri"
          method   = "ALL"
          field    = "uri_path"
          matches  = ["/admin"]
          operator = "or" # and, or
          negate   = false
          action   = "block" # allow, block, count
        },
        {
          enabled  = true
          name     = "block-bad-user-agent"
          method   = "ALL"
          field    = "header:user-agent"
          matches  = ["curl", "wget"]
          operator = "or" # and, or
          negate   = false
          action   = "block" # allow, block, count
        },
        {
          enabled  = true
          name     = "block-ip-range"
          method   = "ALL"
          field    = "ip"
          matches  = ["10.0.0.0/24"]
          operator = "or" # and, or
          negate   = false
          action   = "block" # allow, block, count
        },
        {
          enabled  = true
          name     = "allow-only-safe-query"
          method   = "GET"
          field    = "query_string"
          matches  = ["token="]
          operator = "or" # and, or
          negate   = true
          action   = "block" # allow, block, count
        },
        {
          enabled  = true
          name     = "block-login-attempt-pattern"
          method   = "POST"
          field    = "body"
          matches  = ["username=", "password="]
          operator = "and" # and, or
          negate   = false
          action   = "count" # allow, block, count
        }
      ]
    }
  }
}