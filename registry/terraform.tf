terraform {
  backend "s3" {
    key = "states/root/registry/terraform.tfstate"
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.44.0"
    }
  }
}