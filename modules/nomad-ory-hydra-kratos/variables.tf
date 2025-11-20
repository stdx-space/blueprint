variable "job_name" {
  type    = string
  default = "ory"
}

variable "datacenter_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "default"
}
variable "database_user" {
  type    = string
  default = "ory"
}

variable "database_addr" {
  type = string
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "database_sslmode" {
  type    = string
  default = "disable"
  validation {
    condition     = contains(["disable", "require", "verify-ca", "verify-full"], var.database_sslmode)
    error_message = "The database_sslmode value must be one of: disable, require, verify-ca, verify-full."
  }
}

variable "hydra_db_name" {
  type    = string
  default = "hydra"
}

variable "kratos_db_name" {
  type    = string
  default = "kratos"
}

variable "hydra_version" {
  type = string
}

variable "kratos_version" {
  type = string
}

variable "root_domain" {
  type        = string
  description = "The top level domain name"
}

variable "application_name" {
  type        = string
  description = "Name to identify the application with when using WebAuthn"
}

variable "hydra_subdomain" {
  type    = string
  default = "login"
}

variable "kratos_identity_schema" {
  type = string
}

variable "kratos_recovery_enabled" {
  type    = bool
  default = true
}

variable "kratos_verification_enabled" {
  type    = bool
  default = true
}

variable "kratos_registration_enabled" {
  type    = bool
  default = true
}

variable "kratos_webauthn_enabled" {
  type    = bool
  default = false
}

variable "kratos_passkey_enabled" {
  type    = bool
  default = false
}

variable "kratos_password_policy" {
  type = object({
    min_password_length                 = number
    haveibeenpwned_enabled              = bool
    identifier_similarity_check_enabled = bool
  })
  default = {
    min_password_length                 = 8
    haveibeenpwned_enabled              = true
    identifier_similarity_check_enabled = true
  }
  description = "Password policy configuration for Kratos"
  validation {
    condition     = var.kratos_password_policy.min_password_length >= 6
    error_message = "The min_password_length must be at least 6 characters."
  }
}

variable "kratos_oidc_providers" {
  type = list(object({
    id            = string
    provider      = string
    client_id     = string
    client_secret = string
    data_mapper   = string
  }))
  default     = []
  description = "List of OIDC/OAuth2 providers for social login"
}

variable "kratos_ui_subdomain" {
  type = string
}

variable "kratos_public_subdomain" {
  type    = string
  default = "accounts"
}

variable "kratos_admin_subdomain" {
  type = string
}

variable "smtp_connection_uri" {
  type      = string
  sensitive = true
}

variable "email_from_address" {
  type        = string
  description = "The email address to send emails from"
}

variable "email_from_name" {
  type        = string
  default     = "Account Notifications"
  description = "The name to use when sending emails"
}

variable "registration_webhooks" {
  type = list(object({
    url     = string
    method  = string
    headers = map(string)
    body    = string
  }))
  default = []
}

variable "settings_webhooks" {
  type = list(object({
    url     = string
    method  = string
    headers = map(string)
    body    = string
  }))
  default     = []
  description = "Webhooks to call after settings are updated"
}

variable "traefik_entrypoint" {
  type = object({
    http  = optional(string, "http")
    https = optional(string, "https")
  })
  default = {
    http  = "http"
    https = "https"
  }
  description = "Traefik entrypoint to use"
}

variable "traefik_cert_resolver" {
  type        = string
  default     = ""
  description = "Name of the Traefik certificate resolver for automatic SSL certificates (e.g., 'letsencrypt'). Leave empty to disable automatic certificate management."
}

locals {
  hydra_fqdn         = "${var.hydra_subdomain}.${var.root_domain}"
  kratos_public_fqdn = "${var.kratos_public_subdomain}.${var.root_domain}"
  kratos_admin_fqdn  = "${var.kratos_admin_subdomain}.${var.root_domain}"
  kratos_ui_fqdn     = "${var.kratos_ui_subdomain}.${var.root_domain}"
  kratos_ui_url      = "https://${var.kratos_ui_subdomain}.${var.root_domain}"
}
