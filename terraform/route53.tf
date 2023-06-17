resource "aws_route53_zone" "domain" {
  name = local.domain_name
}


resource "aws_route53_record" "github_pages_verification" {
  name    = "_github-pages-challenge-krewenki"
  ttl     = 60
  records = ["3ae64d1c905aac3b15aaa6abf6663a"]
  type    = "TXT"
  zone_id = aws_route53_zone.domain.zone_id
}

resource "aws_route53_record" "github_pages_www" {
  name    = "www"
  type    = "CNAME"
  ttl     = 60
  records = ["krewenki.github.io"]
  zone_id = aws_route53_zone.domain.zone_id
}

resource "aws_route53_record" "github_pages_root" {
  name = ""
  type = "A"
  ttl  = 60
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
  zone_id = aws_route53_zone.domain.zone_id
}

