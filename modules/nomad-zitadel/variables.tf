variable "datacenter_name" {
  type        = string
  description = "Name of the datacenter"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "Datacenter name cannot be empty"
  }
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "job_name" {
  default     = "zitadel"
  description = "Nomad job name"
}

variable "zitadel_version" {
  default     = "latest"
  description = "Zitadel version to deploy"
}

variable "external_domain" {
  description = "Domain name used to access zitadel externally"
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

variable "postgres_host" {
  default     = "{{ with service `postgres-rw` }}{{ with index . 0 }}{{ .Address }}{{ end }}{{ end }}"
  description = "Postgres host"
}

variable "postgres_port" {
  default     = "{{ with service `postgres-rw` }}{{ with index . 0 }}{{ .Port }}{{ end }}{{ end }}"
  description = "Postgres port"
}

variable "postgres_database" {
  default     = "zitadel"
  description = "Postgres database name"
}

variable "postgres_password" {
  sensitive   = true
  description = "Postgres password"
}

variable "postgres_username" {
  default     = "zitadel"
  description = "Postgres username"
}

variable "postgres_ssl_mode" {
  default     = "disable"
  description = "Postgres ssl mode"
}

variable "postgres_admin_username" {
  default     = "postgres"
  description = "Postgres admin username"
}

variable "postgres_admin_password" {
  sensitive   = true
  description = "Postgres admin password"
}

variable "organization_name" {
  default     = "Zitadel"
  description = "Organization name"
}

variable "root_username" {
  default     = "root"
  description = "Root user username"
}

variable "root_password" {
  default     = ""
  sensitive   = true
  description = "Root user password. Leave empty to generate a random password."
}

variable "masterkey" {
  default     = ""
  sensitive   = true
  description = "Master key used by the zitadel server. Leave empty to generate a random one."
}

variable "resources" {
  type = object({
    cpu    = optional(number, 1000)
    memory = optional(number, 2048)
  })
  default = {
    cpu    = 1000
    memory = 2048
  }
  description = "Resources to run the job with"
}

variable "purge_on_destroy" {
  type        = bool
  default     = false
  description = "Whether to purge the job on destroy"
}
