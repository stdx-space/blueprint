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
  default     = "hasura"
  description = "Nomad job name"
}

variable "hasura_version" {
  default     = "v2.42.0"
  description = "Hasura version to be deployed"
}

variable "hasura_admin_secret" {
  default     = ""
  sensitive   = true
  description = "Hasura admin secret. Leave blank to generate a new one with Terraform random resource."
}

variable "db_address" {
  default     = "{{ with nomadService `postgres` }}{{ with index . 0 }}{{ .Address }}:{{ .Port }}{{ end }}{{ end }}"
  description = "Address of the Postgres database to connect to"
}

variable "db_username" {
  default     = "postgres"
  description = "Username to connect to the Postgres database"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Password to connect to the Postgres database"
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
