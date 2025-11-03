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
  type    = string
  default = "minio"
}

variable "minio_hostname" {
  type    = string
  default = "minio.localhost"
}

variable "minio_superuser_name" {
  type    = string
  default = "minio"
}

variable "minio_superuser_password" {
  default     = ""
  sensitive   = true
  description = "Minio superuser password. Used when generate_superuser_password is false."
}

variable "generate_superuser_password" {
  default     = false
  description = "Whether to generate a Minio superuser password using Terraform random resource. Set to false to use the provided minio_superuser_password instead."
}

variable "create_buckets" {
  type = list(object({
    name   = string
    policy = optional(string, "null")
  }))
  default     = []
  description = "List of buckets to create"

  validation {
    condition     = alltrue([for bucket in var.create_buckets : length(bucket.name) >= 3])
    error_message = "Bucket names must be at least 3 characters long"
  }
}

variable "host_volume_config" {
  type = object({
    source    = string
    read_only = optional(bool, false)
  })
  nullable    = true
  default     = null
  description = "Host volume configuration for storing minio data"
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
  description = "Purge the Typesense Nomad job on destroy"
}

variable "service_discovery_provider" {
  type    = string
  default = "consul"
  validation {
    condition     = contains(["nomad", "consul", "consul-connect"], var.service_discovery_provider)
    error_message = "Service discovery provider must be one of: nomad, consul"
  }
}

variable "enable_https" {
  type        = bool
  default     = false
  description = "Whether HTTPS proxy should be enabled. Used to support TLS only use cases like pgbackrest."
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
