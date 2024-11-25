variable "datacenter_name" {
  type        = string
  description = "Name of the datacenter"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "Datacenter name cannot be empty"
  }
}

variable "job_name" {
  default = "minio"
}

variable "minio_hostname" {
  default = "minio.localhost"
}

variable "minio_superuser_name" {
  default = "minio"
}

variable "minio_superuser_password" {
  default   = ""
  sensitive = true
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
