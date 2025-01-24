variable "bit_length" {
  type        = number
  description = "Bit length of the RSA Key"
  default     = 2048
  validation {
    condition     = (var.bit_length >= 2048 && var.bit_length % 256 == 0)
    error_message = "Bit length must be between 2048 and 4096"
  }
}

variable "ttl" {
  type        = number
  description = "Time in hours until certificate's expiration or its renewal"
  default     = 87660 // 10 Years
  validation {
    condition     = var.ttl >= 1
    error_message = "TTL must be larger than 1"
  }
}

variable "intermediate_ca_ttl" {
  type        = number
  description = "Time in hours until intermediate CA's expiration or its renewal"
  default     = 26298 // 3 Years
}

variable "country" {
  type        = string
  description = "Country for the Root CA certificate"
  default     = "HK"
}

variable "locality" {
  type        = string
  description = "Locality for the Root CA certificate"
  default     = "Hong Kong"
}

variable "root_ca_common_name" {
  type        = string
  description = "Common name for the Root CA certificate"

  validation {
    condition     = length(var.root_ca_common_name) > 0
    error_message = "Root CA common name cannot be empty"
  }
}

variable "root_ca_org_name" {
  type        = string
  description = "Organization Name for the Root CA certficate"
  validation {
    condition     = length(var.root_ca_org_name) > 0
    error_message = "Root CA organization name cannot be empty"
  }
}

variable "root_ca_org_unit" {
  type        = string
  description = "Organizational Unit for the Root CA certifcate"
}

variable "extra_client_certificates" {
  type = list(object({
    common_name = string
  }))
  description = "List of common names to generate client certificates for"
  default     = []
}

variable "extra_server_certificates" {
  type = list(object({
    san_dns_names    = list(string)
    san_ip_addresses = list(string)
    ttl              = optional(number, 13149) // 1.5 Years
  }))
  description = "List of domain names to generate server certificates for"
  default     = []
}

locals {
  dns_ip_map = {
    for key in var.extra_server_certificates : key.san_dns_names[0] => key.san_ip_addresses
  }
  clients = { for client in var.extra_client_certificates : client.common_name => client }
  servers = {
    for signing_request in var.extra_server_certificates : signing_request.san_dns_names[0] => {
      dns_names    = signing_request.san_dns_names
      ip_addresses = signing_request.san_ip_addresses
    }
  }
}
