variable "supplychain" {
  type    = string
  default = "https://artifact.narwhl.dev/upstream/current.json"
}

variable "data_dir" {
  type        = string
  default     = "/opt/vault"
  description = "Directory for storing runtime data for Vault"
}

variable "install_dir" {
  type        = string
  default     = "/mnt/install"
  description = "Directory for installing Vault"
}

variable "log_level" {
  type        = string
  default     = "info"
  description = "Log level for Vault"
  validation {
    condition     = var.log_level == "debug" || var.log_level == "info" || var.log_level == "warn" || var.log_level == "error" || var.log_level == "trace"
    error_message = "Log level must be one of debug, info, warn, error, or trace"
  }
}

variable "access_key" {
  type        = string
  sensitive   = true
  description = "Access key for S3 bucket"
  validation {
    condition     = length(var.access_key) > 0
    error_message = "Must specify access_key"
  }
}

variable "secret_key" {
  type        = string
  sensitive   = true
  description = "Secret key for S3 bucket"
  validation {
    condition     = length(var.secret_key) > 0
    error_message = "Must specify secret_key"
  }
}

variable "s3_endpoint" {
  type        = string
  description = "Endpoint URL for S3 bucket"
  validation {
    condition     = length(var.s3_endpoint) > 0
    error_message = "Must specify s3_endpoint"
  }
}

variable "bucket" {
  type        = string
  description = "S3 bucket name"
  validation {
    condition     = length(var.bucket) > 0
    error_message = "Must specify bucket"
  }
}

variable "acme_email" {
  type        = string
  description = "Email for account registration ACME provider"
  validation {
    condition     = length(var.acme_email) > 0
    error_message = "Must specify acme_email"
  }
}

variable "acme_domain" {
  type        = string
  description = "Domain to apply certifciate for"
  validation {
    condition     = length(var.acme_domain) > 0
    error_message = "Must specify acme_domain"
  }
}

variable "cf_zone_token" {
  type        = string
  description = "Cloudflare api token read all zones info"
  validation {
    condition     = length(var.cf_zone_token) > 0
    error_message = "Cloudflare ZONE token must be provided for Let's Encrypt DNS challenge"
  }
}

variable "cf_dns_token" {
  type        = string
  description = "Cloudflare api token to edit specific zone dns"
  validation {
    condition     = length(var.cf_dns_token) > 0
    error_message = "Cloudflare DNS token must be provided for Let's Encrypt DNS challenge"
  }
}

variable "webhook_url" {
  type        = string
  description = "webhook endpoint for unseal/init"
}
