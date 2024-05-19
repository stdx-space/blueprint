terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}
