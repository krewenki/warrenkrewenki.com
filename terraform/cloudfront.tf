module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = [local.domain_name, "www.${local.domain_name}"]

  comment             = local.domain_name
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  wait_for_deployment = true

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = format("%s cloudfront access", local.domain_name)
  }

  origin = {
    s3_one = {
      domain_name = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_one"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  default_root_object = "index.html"

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.ssl_certificate.arn
    ssl_support_method             = "sni-only"
  }

}
