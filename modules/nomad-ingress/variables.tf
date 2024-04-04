variable "controller_job_name" {
  type    = string
  default = "ingress-controller"
}

variable "gateway_job_name" {
  type    = string
  default = "ingress-gateway"
}

variable "dns_zone_name" {
  type        = string
  description = "Name of the DNS zone"
  validation {
    condition     = length(var.dns_zone_name) > 0
    error_message = "DNS zone name cannot be empty"
  }
}

variable "cloudflare_account_id" {
  type        = string
  sensitive   = true
  description = "Cloudflare account ID"
  validation {
    condition     = length(var.cloudflare_account_id) > 0
    error_message = "Cloudflare account ID cannot be empty"
  }
}

variable "acme_email" {
  type        = string
  default     = ""
  description = "Email address used for acme registration"
}

variable "datacenter_name" {
  type        = string
  description = "Name of the datacenter"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "Datacenter name cannot be empty"
  }
}

variable "traefik_version" {
  type        = string
  description = "Version of traefik to deploy"
  validation {
    condition     = length(var.traefik_version) > 0
    error_message = "Traefik version cannot be empty"
  }
}

variable "cloudflared_version" {
  type        = string
  description = "Version of cloudflared to deploy"
  validation {
    condition     = length(var.cloudflared_version) > 0
    error_message = "Cloudflared version cannot be empty"
  }
}

variable "static_routes" {
  type        = string
  description = "Traefik dynamic configuration for configuring static routes"
  default     = ""
}
