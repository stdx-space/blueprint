terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.33.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}
