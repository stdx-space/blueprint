variable "supplychain" {
  type    = string
  default = "https://artifact.narwhl.dev/upstream/current.json"
}

variable "domain" {
  type        = string
  description = "Domain name for the Vault instance"
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

variable "skip_create_bucket" {
  type    = bool
  default = true
}

variable "bucket" {
  type        = string
  description = "S3 bucket name"
  default     = "vault"
  validation {
    condition     = length(var.bucket) > 0
    error_message = "Must specify bucket"
  }
}

variable "webhook_url" {
  type        = string
  description = "webhook endpoint for unseal/init"
}
