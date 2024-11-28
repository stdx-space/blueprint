variable "job_name" {
  type    = string
  default = "ory"
}

variable "datacenter_name" {
  type = string
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

variable "kratos_passkey_enabled" {
  type    = bool
  default = false
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

variable "registration_webhooks" {
  type = list(object({
    url     = string
    method  = string
    headers = map(string)
    body    = string
  }))
  default = []
}

locals {
  hydra_fqdn         = "${var.hydra_subdomain}.${var.root_domain}"
  kratos_public_fqdn = "${var.kratos_public_subdomain}.${var.root_domain}"
  kratos_admin_fqdn  = "${var.kratos_admin_subdomain}.${var.root_domain}"
  kratos_ui_url      = "https://${var.kratos_ui_subdomain}.${var.root_domain}"
}
