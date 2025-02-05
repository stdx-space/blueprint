variable "supplychain" {
  type    = string
  default = "https://artifact.narwhl.dev/upstream/current.json"
}

variable "consul_auth_token" {
  type = string
  description = "Consul ACL token"
  sensitive = true
}