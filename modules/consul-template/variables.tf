variable "supplychain" {
  type    = string
  default = "https://artifact.narwhl.dev/upstream/current.json"
}

variable "consul_auth_token" {
  type        = string
  description = "Consul ACL token"
  sensitive   = true
}

variable "consul_address" {
  type        = string
  description = "Consul address"
}

variable "templates" {
  type = map(object({
    contents    = optional(string, "")
    destination = string
    exec        = list(string)
    owner       = optional(string, "root")
    group       = optional(string, "root")
    mode        = optional(string, "0644")
  }))

  validation {
    condition     = length(keys(var.templates)) > 0
    error_message = "At least one template must be defined"
  }

  validation {
    condition     = alltrue([for template in values(var.templates) : length(template.destination) > 0])
    error_message = "Template destination cannot be empty"
  }
}
