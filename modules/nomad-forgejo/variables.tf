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
  default = "forgejo"
}

variable "service_discovery_provider" {
  type    = string
  default = "consul"
  validation {
    condition     = contains(["nomad", "consul"], var.service_discovery_provider)
    error_message = "Service discovery provider must be one of: nomad, consul"
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
  default     = false
  description = "Purge the Typesense Nomad job on destroy"
}

variable "forgejo_version" {
  description = "The version of Forgejo to install."
  default     = "10"
}

variable "litestream_version" {
  description = "The version of Litestream to install."
  default     = "0.3.13"
}

variable "restic_version" {
  description = "The version of restic to install."
  default     = "0.17.3"
}

variable "traefik_entrypoint" {
  type = object({
    http  = optional(string, "http")
    https = optional(string, "https")
    ssh   = optional(string, "ssh")
  })
  default = {
    http  = "http"
    https = "https"
    ssh   = "ssh"
  }
  description = "Traefik entrypoint to use"
}

variable "app_name" {
  description = "The name of the Forgejo application."
  default     = "Git @ Example Org"
}

variable "domain" {
  type        = string
  description = "The domain name to use for the Forgejo server. For example, forgejo.example.com."
}

variable "ssh_domain" {
  type        = string
  description = "The domain name to use for SSH access. For example, ssh.example.com."
}

variable "protocol" {
  description = "Protocol of Forgejo site. This should be kept https."
  default     = "https"
}

variable "db_type" {
  description = "The type of database to use for Forgejo. Only sqlite is supported at this time."
  default     = "sqlite3"
}

variable "external_ssh_port" {
  description = "The port to use for external SSH access."
  default     = 22
}

variable "disable_registration" {
  description = "Whether to disable registration of new users."
  default     = false
}

variable "require_signin_view" {
  description = "Whether to require users to sign in before accessing the Forgejo web UI."
  default     = false
}

variable "minio_endpoint" {
  type        = string
  description = "The endpoint for the Minio server."
}

variable "minio_access_key" {
  type        = string
  description = "The access key for the Minio server."
}

variable "minio_secret_key" {
  type        = string
  description = "The secret key for the Minio server."
  sensitive   = true
}

variable "minio_data_bucket" {
  description = "The bucket to use for Forgejo's storage."
  default     = "forgejo-data"
}

variable "minio_replication_bucket" {
  description = "The bucket to use for Forgejo's litestream SQLite replication."
  default     = "forgejo-litestream"
}

variable "minio_backup_bucket" {
  description = "The bucket to use for Forgejo's backups."
  default     = "forgejo-backup"
}

variable "minio_use_ssl" {
  type        = bool
  description = "Whether to use SSL for the Minio server."
  default     = true
}

variable "minio_checksum_algorithm" {
  description = "The checksum algorithm to use for Minio. default (for MinIO or AWS S3) or md5 (for Cloudflare or Backblaze)"
  default     = "default"
}

variable "restic_password" {
  type        = string
  description = "The password to use for restic."
  sensitive   = true
}

variable "backup_schedule" {
  description = "Backup schedule of repository data in cron format. Default is backing up every 5 minutes."
  default     = "*/5 * * * *"
}
