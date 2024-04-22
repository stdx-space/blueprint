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

variable "bucket" {
  type        = string
  description = "S3 bucket name"
  validation {
    condition     = length(var.bucket) > 0
    error_message = "Must specify bucket"
  }
}

variable "zone" {
  type        = string
  description = "DNS zone the Vault service will place its subdomain in"
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID for access"
}

variable "cloudflare_access_service_token_id" {
  type        = string
  description = "Cloudflare access service token ID"
}

variable "github_organization" {
  type        = string
  description = "GitHub organization handle"
}

variable "request_origin_ip_domain" {
  type        = string
  description = "Domain name for which to lookup the public ip of the organization owned network"
}

variable "webhook_url" {
  type        = string
  description = "webhook endpoint for unseal/init"
}

variable "min_days_for_renewal" {
  type        = number
  default     = 7
  description = "Minimum number of days before expiration to renew the certificate"
}

variable "cf_origin_ca_cert_ttl" {
  type        = number
  default     = 365
  description = "Days to expiry for the Cloudflare Origin CA certificate"
}
