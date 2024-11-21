variable "datacenter_name" {
  type        = string
  description = "Name of the datacenter"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "Datacenter name cannot be empty"
  }
}

variable "job_name" {
  default     = "redis"
  description = "Nomad job name"
}

variable "redis_version" {
  default     = "7"
  description = "Redis version to be deployed"
}

variable "host_volume_config" {
  type = object({
    source    = string
    read_only = optional(bool, false)
  })
  nullable    = true
  default     = null
  description = "Host volume configuration for storing redis data"
}

variable "enable_ephemeral_disk" {
  type        = bool
  default     = false
  description = "Enable Nomad ephemeral disk for the storing Redis data temporarily. Cannot be used with host volumes."
}

variable "purge_on_destroy" {
  type        = bool
  default     = false
  description = "Purge the Typesense Nomad job on destroy"
}

variable "persistent_config" {
  type = object({
    save_options = optional(string, "60 1")
  })
  description = "Persistent configuration for Redis"
}
