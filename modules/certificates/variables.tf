variable "ca_cert_pem" {
  type        = string
  description = "PEM-encoded CA certificate"
}

variable "ca_private_key_pem" {
  type        = string
  description = "PEM-encoded CA private key"
  sensitive   = true
}

variable "bit_length" {
  type        = number
  description = "Bit length of the RSA Key"
  default     = 2048
  validation {
    condition     = (var.bit_length >= 2048 && var.bit_length % 256 == 0)
    error_message = "Bit length must be between 2048 and 4096"
  }
}

variable "client" {
  type = list(object({
    common_name = string
    ttl         = optional(number, 6574) // 9 Months
  }))
  description = "List of common names to generate client certificates for"
  default     = []
}

variable "server" {
  type = list(object({
    san_dns_names    = list(string)
    san_ip_addresses = list(string)
    ttl              = optional(number, 13149) // 1.5 Years
  }))
  description = "List of domain names to generate server certificates for"
  default     = []
}

