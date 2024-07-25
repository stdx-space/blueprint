terraform {
  required_providers {
    k0s = {
      source  = "alessiodionisi/k0s"
      version = "0.2.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}
