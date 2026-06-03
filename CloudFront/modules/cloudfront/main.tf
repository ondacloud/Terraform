data "aws_iam_policy_document" "s3" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_bucket_arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cf.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cdn_oac_policy" {
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3_oac_policy"
  description                       = "s3_oac_policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cf" {
    origin {
      domain_name              = var.s3_bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
      origin_id                = "s3_origin"
      origin_path              = var.origin_path
    }

    enabled             = true
    is_ipv6_enabled     = false
    comment             = "CloudFront For S3, ALB"
    default_root_object = var.default_root_object
    
    default_cache_behavior {
        cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"
        target_origin_id = "s3_origin"
        

        allowed_methods = ["GET", "HEAD"]
        cached_methods  = ["GET", "HEAD"]

        compress = true
        viewer_protocol_policy = "redirect-to-https"
    }
    price_class = "PriceClass_All"

    restrictions {
      geo_restriction {
        restriction_type = "none"
        locations        = []
      }
    }
    
    viewer_certificate {
      cloudfront_default_certificate = true
    }

    web_acl_id = var.enable_waf ? var.waf_id : null
    
    tags = var.tags
}