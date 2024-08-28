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
