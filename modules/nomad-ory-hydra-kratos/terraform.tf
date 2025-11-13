terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}
