variable "supplychain" {
  type    = string
  default = "https://artifact.narwhl.dev/upstream/current.json"
}

variable "data_dir" {
  type        = string
  default     = "/opt/consul"
  description = "Directory for storing runtime data for Consul"
}

variable "datacenter_name" {
  type        = string
  description = "Name of datacenter consul server will use to identify itself"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "Datacenter name cannot be empty"
  }
}

variable "gossip_key" {
  type        = string
  description = "Gossip Encryption Key for Consul inter-client/server communications"
  default     = ""
  sensitive   = true
}

variable "bootstrap_expect" {
  type        = number
  default     = 1
  description = "Number of consul instance connection expected to form the cluster"

  validation {
    condition     = var.bootstrap_expect % 2 == 1
    error_message = "Bootstrap Expect cannot be even number due to the inability to reach consensus in a quorum"
  }

  validation {
    condition     = var.bootstrap_expect > 0
    error_message = "Bootstrap Expect cannot be zero or negative"
  }
}

variable "retry_join" {
  type        = list(string)
  description = "Parameter value for DNS address, IP address or cloud auto-join configuration"
  default     = []
}

variable "log_level" {
  type        = string
  default     = "INFO"
  description = "Log level for Consul agent"
  validation {
    condition     = var.log_level == "DEBUG" || var.log_level == "INFO" || var.log_level == "WARN"
    error_message = "Log level must be one of debug, info, warn"
  }
}

variable "role" {
  type        = string
  default     = "client"
  description = "Role of the consul agent"
  validation {
    condition     = var.role == "server" || var.role == "client"
    error_message = "Role must be either server or client"
  }
}

variable "resolve_consul_domains" {
  type        = bool
  default     = false
  description = "Whether to point DNS records for *.service.consul to the consul servers"
}

variable "tls" {
  type = object({
    ca_cert = optional(object({
      path    = string
      content = string
    }))
    server_cert = optional(object({
      path    = string
      content = string
    }))
    server_key = optional(object({
      path    = string
      content = string
    }))
  })
  default = {
    ca_cert = {
      path    = "/etc/consul.d/tls/ca.pem"
      content = ""
    }
    server_cert = {
      path    = "/etc/consul.d/tls/server.pem"
      content = ""
    }
    server_key = {
      path    = "/etc/consul.d/tls/server.key"
      content = ""
    }
  }
  description = "TLS configuration for Consul"
}

resource "random_id" "gossip_key" {
  byte_length = 32
}

locals {
  gossip_key = 0 < length(var.gossip_key) ? var.gossip_key : random_id.gossip_key.b64_std
  server_tls_keypair = {
    client = {}
    server = {
      cert_file = var.tls.server_cert.path
      key_file  = var.tls.server_key.path
    }
  }[var.role]
}
