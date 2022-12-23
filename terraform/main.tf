locals {
  domain_name = "warrenkrewenki.com"
  bucket_name = format("www.%s", local.domain_name)
}

data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.6.0"

  bucket = local.bucket_name

  # Bucket policies
  #   attach_policy                         = true
  #   policy                                = data.aws_iam_policy_document.bucket_policy.json
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # S3 Bucket Ownership Controls
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  acl = "private" # "acl" conflicts with "grant" and "owner"

  versioning = {
    status     = true
    mfa_delete = false
  }

  website = {
    # conflicts with "error_document"
    #        redirect_all_requests_to = {
    #          host_name = "https://modules.tf"
    #        }

    index_document = "index.html"
    error_document = "error.html"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  cors_rule = [
    {
      allowed_methods = ["PUT", "POST"]
      allowed_origins = ["https://${local.domain_name}", "https://www.${local.domain_name}"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
      }, {
      allowed_methods = ["GET"]
      allowed_origins = ["https://${local.domain_name}", "https://www.${local.domain_name}"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]


  #   intelligent_tiering = {
  #     general = {
  #       status = "Enabled"
  #       filter = {
  #         prefix = "/"
  #         tags = {
  #           Environment = "dev"
  #         }
  #       }
  #       tiering = {
  #         ARCHIVE_ACCESS = {
  #           days = 180
  #         }
  #       }
  #     },
  #     documents = {
  #       status = false
  #       filter = {
  #         prefix = "documents/"
  #       }
  #       tiering = {
  #         ARCHIVE_ACCESS = {
  #           days = 125
  #         }
  #         DEEP_ARCHIVE_ACCESS = {
  #           days = 200
  #         }
  #       }
  #     }
  #   }

}

# SSL Certificate
resource "aws_acm_certificate" "ssl_certificate" {
  provider                  = aws.acm_provider
  domain_name               = local.domain_name
  subject_alternative_names = ["*.${local.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Uncomment the validation_record_fqdns line if you do DNS validation instead of Email.
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.ssl_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
