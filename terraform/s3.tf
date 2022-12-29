module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.6.0"

  bucket = local.bucket_name

  acl           = "private" # "acl" conflicts with "grant" and "owner"
  force_destroy = true

}

data "aws_iam_policy_document" "s3_policy" {
  version = "2012-10-17"
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }
  }
}

resource "aws_s3_bucket_policy" "docs" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}
