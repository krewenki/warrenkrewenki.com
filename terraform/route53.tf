resource "aws_route53_zone" "domain" {
  name = local.domain_name
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.domain.zone_id
}

resource "aws_route53_record" "root" {
  name = local.domain_name
  #records = [module.cloudfront.cloudfront_distribution_domain_name]
  type    = "A"
  zone_id = aws_route53_zone.domain.zone_id
  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  name    = "www"
  records = [module.cloudfront.cloudfront_distribution_domain_name]
  ttl     = 60
  type    = "CNAME"
  zone_id = aws_route53_zone.domain.zone_id
}


