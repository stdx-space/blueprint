variable "datacenter_name" {
  type        = string
  description = "Name of the datacenter"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "Datacenter name cannot be empty"
  }
}

variable "namespace" {
  type        = string
  default     = "default"
  description = "Nomad namespace"
}

variable "job_name" {
  type        = string
  default     = "openfga"
  description = "Nomad job name"
}

variable "openfga_version" {
  type        = string
  default     = "latest"
  description = "OpenFGA version to deploy"
}

# Datastore Configuration
variable "datastore" {
  type = object({
    engine = optional(string, "postgres")
    uri    = optional(string, "")
    postgres = optional(object({
      host     = optional(string, "{{ with service `postgres-rw` }}{{ with index . 0 }}{{ .Address }}{{ end }}{{ end }}")
      port     = optional(string, "{{ with service `postgres-rw` }}{{ with index . 0 }}{{ .Port }}{{ end }}{{ end }}")
      database = optional(string, "openfga")
      username = optional(string, "openfga")
      password = optional(string, "")
      ssl_mode = optional(string, "disable")
    }), {})
  })
  default = {
    engine   = "postgres"
    uri      = ""
    postgres = {}
  }
  description = "Datastore configuration. Supports postgres, mysql, or sqlite. Provide either uri or individual connection parameters."
  sensitive   = true

  validation {
    condition     = contains(["postgres", "mysql", "sqlite"], var.datastore.engine)
    error_message = "Datastore engine must be postgres, mysql, or sqlite"
  }
}

# Authentication Configuration
variable "authn_method" {
  type        = string
  default     = "preshared"
  description = "Authentication method: none, preshared, or oidc"
  validation {
    condition     = contains(["none", "preshared", "oidc"], var.authn_method)
    error_message = "Authentication method must be none, preshared, or oidc"
  }
}

variable "authn_preshared_keys" {
  type        = list(string)
  default     = []
  sensitive   = true
  description = "List of preshared keys for authentication. Leave empty to generate random keys."
}

variable "authn_oidc_issuer" {
  type        = string
  default     = ""
  description = "OIDC issuer URL (required if authn_method is oidc)"
}

variable "authn_oidc_audience" {
  type        = string
  default     = ""
  description = "OIDC audience (required if authn_method is oidc)"
}

variable "authn_oidc_client_id_claims" {
  type        = list(string)
  default     = ["azp", "client_id"]
  description = "OIDC client ID claims in order of priority"
}

# TLS Configuration
variable "http_tls_enabled" {
  type        = bool
  default     = false
  description = "Enable TLS for HTTP server"
}

variable "http_tls_cert" {
  type        = string
  default     = ""
  description = "Path to HTTP TLS certificate file"
}

variable "http_tls_key" {
  type        = string
  default     = ""
  description = "Path to HTTP TLS key file"
}

variable "grpc_tls_enabled" {
  type        = bool
  default     = false
  description = "Enable TLS for gRPC server"
}

variable "grpc_tls_cert" {
  type        = string
  default     = ""
  description = "Path to gRPC TLS certificate file"
}

variable "grpc_tls_key" {
  type        = string
  default     = ""
  description = "Path to gRPC TLS key file"
}

# Production Settings
variable "playground_enabled" {
  type        = bool
  default     = false
  description = "Enable the playground (disable in production)"
}

variable "log_format" {
  type        = string
  default     = "json"
  description = "Log format: text or json"
  validation {
    condition     = contains(["text", "json"], var.log_format)
    error_message = "Log format must be text or json"
  }
}

variable "log_level" {
  type        = string
  default     = "info"
  description = "Log level: debug, info, warn, error"
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be debug, info, warn, or error"
  }
}

variable "metrics_enabled" {
  type        = bool
  default     = true
  description = "Enable metrics collection"
}

variable "datastore_metrics_enabled" {
  type        = bool
  default     = true
  description = "Enable datastore metrics"
}

variable "trace_enabled" {
  type        = bool
  default     = false
  description = "Enable distributed tracing"
}

variable "trace_sample_ratio" {
  type        = number
  default     = 0.3
  description = "Trace sample ratio (0.0 to 1.0)"
  validation {
    condition     = var.trace_sample_ratio >= 0.0 && var.trace_sample_ratio <= 1.0
    error_message = "Trace sample ratio must be between 0.0 and 1.0"
  }
}

# Resource Configuration
variable "resources" {
  type = object({
    cpu    = optional(number, 500)
    memory = optional(number, 512)
  })
  default = {
    cpu    = 500
    memory = 512
  }
  description = "Resources to allocate for OpenFGA"
}

variable "purge_on_destroy" {
  type        = bool
  default     = false
  description = "Whether to purge the job on destroy"
}
