variable "supplychain" {
  type    = string
  default = "https://artifact.narwhl.dev/upstream/current.json"
}

variable "auth_key" {
  type        = string
  description = "Tailscale auth key"
  sensitive   = true
}