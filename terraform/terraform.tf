terraform {
  required_version = ">= 1.2.0"

  backend "s3" {
    bucket         = "krewenki-tfstate"
    key            = "sites/warrenkrewenki.com/terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    dynamodb_table = "krewenki-tfstate-lock"
  }
}
