variable "vaultwarden_version" {
  type        = string
  description = "Vaultwarden version"
  validation {
    condition     = length(var.vaultwarden_version) > 0
    error_message = "Vaultwarden server version must be set"
  }
}

variable "restic_version" {
  type        = string
  description = "Restic version"
  validation {
    condition     = length(var.restic_version) > 0
    error_message = "Restic version must be set"
  }
}

variable "litestream_version" {
  type        = string
  description = "Litestream version"
  validation {
    condition     = length(var.litestream_version) > 0
    error_message = "Litestream version must be set"
  }
}

variable "job_name" {
  type        = string
  description = "Name of the Nomad job"
  default     = "vaultwarden"
  validation {
    condition     = length(var.job_name) > 0
    error_message = "Job name cannot be empty"
  }
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "datacenter_name" {
  type        = string
  description = "Name of the datacenter"
  default     = "dc1"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "Datacenter name cannot be empty"
  }
}

variable "resources" {
  type = object({
    cpu    = optional(number, 1024)
    memory = optional(number, 1024)
  })
  default = {
    cpu    = 1024
    memory = 1024
  }
  description = "Resources to run the job with"
}

variable "purge_on_destroy" {
  type        = bool
  description = "Purge nomad job on destroy"
  default     = true
}

variable "fqdn" {
  type        = string
  description = "FQDN of the Vaultwarden server, i.e. vaultwarden.example.com"
  validation {
    condition     = length(var.fqdn) > 0
    error_message = "FQDN cannot be empty"
  }
}

variable "s3_access_key" {
  type        = string
  description = "S3 access key"
  sensitive   = true
  validation {
    condition     = length(var.s3_access_key) > 0
    error_message = "S3 access key cannot be empty"
  }
}

variable "s3_secret_key" {
  type        = string
  description = "S3 secret key"
  sensitive   = true
  validation {
    condition     = length(var.s3_secret_key) > 0
    error_message = "S3 secret key cannot be empty"
  }
}

variable "s3_replication_bucket" {
  type        = string
  description = "S3 bucket for Litestream replication"
  validation {
    condition     = length(var.s3_replication_bucket) > 0
    error_message = "S3 replication bucket cannot be empty"
  }
}

variable "s3_endpoint" {
  type        = string
  description = "S3 endpoint"
  validation {
    condition     = length(var.s3_endpoint) > 0
    error_message = "S3 endpoint cannot be empty"
  }
}

variable "s3_use_ssl" {
  type        = bool
  description = "Use SSL for S3"
  default     = true
}

variable "s3_backup_bucket" {
  type        = string
  description = "S3 bucket for Restic backups"
  validation {
    condition     = length(var.s3_backup_bucket) > 0
    error_message = "S3 backup bucket cannot be empty"
  }
}

variable "restic_password" {
  type        = string
  sensitive   = true
  description = "Restic password"
  validation {
    condition     = length(var.restic_password) > 0
    error_message = "Restic password cannot be empty"
  }
}

variable "backup_schedule" {
  description = "Backup schedule of repository data in cron format. Default is backing up every 5 minutes."
  default     = "*/5 * * * *"
}

variable "service_discovery_provider" {
  type    = string
  default = "consul"
  validation {
    condition     = contains(["nomad", "consul"], var.service_discovery_provider)
    error_message = "Service discovery provider must be one of: nomad, consul"
  }
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