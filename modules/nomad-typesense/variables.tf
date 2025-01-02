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
  default     = "typesense"
  description = "Nomad job name"
}

variable "typesense_version" {
  default     = "latest"
  description = "Typesense version to be deployed"
}

variable "typesense_api_key" {
  default     = ""
  sensitive   = true
  description = "Typesense API key. Leave blank to generate a new one with Terraform random resource."
}

variable "host_volume_config" {
  type = object({
    source    = string
    read_only = optional(bool, false)
  })
  nullable    = true
  default     = null
  description = "Host volume configuration for storing typesense data"
}

variable "enable_ephemeral_disk" {
  type        = bool
  default     = false
  description = "Enable Nomad ephemeral disk for the storing typesense data temporarily. Cannot be used with host volumes."
}

variable "purge_on_destroy" {
  type        = bool
  default     = false
  description = "Purge the Typesense Nomad job on destroy"
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
