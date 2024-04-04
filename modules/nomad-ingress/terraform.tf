terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.19.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.19.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.0.0"
    }
  }
}
