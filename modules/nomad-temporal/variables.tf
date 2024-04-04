variable "job_name" {
  type    = string
  default = "temporal" 
}

variable "datacenter_name" {
  type        = string
  description = "Name of datacenter to deploy jobs to"
  default     = "dc1"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "Datacenter name must be set"
  }
}

variable "elasticsearch_version" {
  type        = string
  description = "Elasticsearch version"
  validation {
    condition     = length(var.elasticsearch_version) > 0
    error_message = "Elasticsearch version must be set"
  }
}

variable "postgres_version" {
  type        = string
  description = "Postgresql server version"
  validation {
    condition     = length(var.postgres_version) > 0
    error_message = "Postgresql server version must be set"
  }
}

variable "temporal_version" {
  type        = string
  description = "Temporal server version"
  validation {
    condition     = length(var.temporal_version) > 0
    error_message = "Temporal server version must be set"
  }
}

variable "temporal_ui_version" {
  type        = string
  description = "Temporal UI version"
  validation {
    condition     = length(var.temporal_ui_version) > 0
    error_message = "Temporal UI version must be set"
  }
}
