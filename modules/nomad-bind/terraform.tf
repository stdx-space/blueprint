terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.21.1"
    }
  }
}

provider "tailscale" {
  oauth_client_id = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
}