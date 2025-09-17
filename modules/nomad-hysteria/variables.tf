variable "job_name" {
  type    = string
  default = "obfs-proxy"
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

variable "namespace" {
  type    = string
  default = "default"
}

variable "purge_on_destroy" {
  type        = bool
  description = "Whether to purge all jobs on destroy"
  default     = true
}

variable "masquerade_url" {
  type    = string
  default = "https://www.bing.com/"
}

variable "obfs_type" {
  type    = string
  default = "salamander"
}

variable "obfs_password" {
  type      = string
  sensitive = true
}

variable "auth_password" {
  type      = string
  sensitive = true
}

variable "listen_port" {
  type    = number
  default = 8443
}

variable "bind_port" {
  type    = number
  default = 8443
}

variable "cert_common_name" {
  type    = string
  default = "hysteria.local"
}

variable "cert_organization" {
  type    = string
  default = "Hysteria"
}

variable "cert_ttl" {
  type    = number
  default = 87600
}