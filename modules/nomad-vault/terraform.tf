terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.48.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.17.2"
    }
  }
}
