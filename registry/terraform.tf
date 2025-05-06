terraform {
  backend "http" {}
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.4.0"
    }
  }
}
