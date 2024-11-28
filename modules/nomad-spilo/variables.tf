variable "job_name" {
  type        = string
  description = "Name of the Nomad job"
  default     = "spilo"
}

variable "postgres_init_job_name" {
  type        = string
  description = "Name of the Postgres init job"
  default     = "postgres-init"
}

variable "datacenter_name" {
  type        = string
  description = "Name of the datacenter to deploy to"
}

variable "spilo_version" {
  default     = "spilo-16:3.2-p2"
  description = "Spilo version to deploy"
}

variable "nodes" {
  type        = list(string)
  description = "List of nodes to deploy to"
}

variable "s3_config" {
  type = object({
    wal_bucket = string
    access_key = string
    secret_key = string
    endpoint   = string
  })
  description = "S3 configuration for the spilo cluster WAL bucket"
}

variable "postgres_superuser_username" {
  type        = string
  default     = "postgres"
  description = "Username of the postgres superuser"
}

variable "postgres_superuser_password" {
  type        = string
  description = "Password of the postgres superuser"
}

variable "postgres_init" {
  type = list(object({
    database    = string
    user        = optional(string, "")
    password    = optional(string, "")
    create_user = optional(bool, true)
  }))
  default     = []
  description = "The PostgreSQL databases and users to be created. The user will have the same name as the database if not specified. Leave password empty if it should be generated. Can be in Go (Nomad) template syntax for accessing Consul K/V, Vault secrets or Nomad variables, etc."
  sensitive   = true
}

variable "postgres_init_script" {
  type        = string
  default     = ""
  description = "The PostgreSQL database initialization script"
}

variable "backup_schedule" {
  type        = string
  default     = "0 0 * * *"
  description = "The cron schedule for backups"
}

variable "purge_on_destroy" {
  type        = bool
  description = "Whether to purge the job on destroy"
  default     = false
}
