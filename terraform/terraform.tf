terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket         = "krewenki-tfstate"
    key            = "sites/warrenkrewenki.com/terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    dynamodb_table = "krewenki-tfstate-lock"
  }
}

provider "aws" {
  region = "ca-central-1"
  default_tags {
    tags = {
      "Project"     = "warrenkrewenki.com"
      "Provisioner" = "terraform"
    }
  }
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}
