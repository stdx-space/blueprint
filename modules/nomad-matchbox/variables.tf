variable "datacenter_name" {
  type        = string
  description = "The name of the nomad datacenter"
  default     = "dc1"
}

variable "job_name" {
  type        = string
  description = "The name of the nomad job"
  default     = "matchbox"
}

variable "namespace" {
  type        = string
  description = "The namespace of the nomad job"
  default     = "default"
}

variable "dhcp_range" {
  type        = list(string)
  description = "DHCP range to issue IPs from and to"

  validation {
    condition     = length(var.dhcp_range) == 2
    error_message = "DHCP range must be a list of two strings"
  }
}

variable "grpc_tls_cert" {
  type        = string
  description = "The gRPC server certificate"
}

variable "grpc_tls_key" {
  type        = string
  description = "The gRPC server key"
}

variable "ca_cert_pem" {
  type        = string
  description = "The CA certificate"
}

variable "matchbox_url" {
  type        = string
  description = "The URL of the Matchbox server"
}

variable "matchbox_version" {
  type        = string
  description = "The version of Matchbox to use"
}

variable "dnsmasq_version" {
  type        = string
  description = "The version of dnsmasq to use, sourcing from quay.io/poseidon/dnsmasq"
}

variable "flatcar_version" {
  type        = string
  description = "The version of Flatcar Container Linux to use"
}

variable "talos_version" {
  type        = string
  description = "The version of Talos Linux to use"
}

variable "talos_schematic_id" {
  type        = string
  description = "The schematic ID of the Talos Linux image"
}
