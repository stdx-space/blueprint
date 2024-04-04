variable "supplychain" {
  type    = string
  default = "https://artifact.narwhl.dev/upstream/current.json"
}

variable "name" {
  type        = string
  description = "Hostname of the Debian VM"
}

variable "default_packages" {
  type = list(string)
  default = [
    "apt-transport-https",
    "containerd.io",
    "docker-ce",
    "docker-ce-cli",
    "docker-buildx-plugin",
    "docker-compose-plugin",
    "dnsutils",
    "git",
    "jq",
    "net-tools",
    "podman",
    "prometheus-node-exporter",
    "qemu-guest-agent",
    "rsync",
    "vim",
  ]
}

variable "username" {
  type        = string
  default     = "system"
  description = "Login user"
  validation {
    condition     = length(var.username) > 0
    error_message = "Username must be set"
  }
}

variable "password" {
  type        = string
  description = "Login password in console, ssh login is key only."
  default     = ""
  sensitive   = true
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "SSH public keys"
  validation {
    condition     = length(var.ssh_authorized_keys) > 0
    error_message = "At least one SSH public key must be set to prevent locked out"
  }
}

variable "timezone" {
  type        = string
  default     = "Asia/Hong_Kong"
  description = "Timezone for the Debian VM"
}

variable "disks" {
  type = list(object({
    label       = string
    mount_path  = string
    device_path = string
  }))
  default     = []
  description = "List of disk configurations"
}

variable "expose_docker_socket" {
  type        = bool
  default     = false
  description = "Whether to expose the Docker socket to the VM"
}

variable "network" {
  type        = string
  default     = ""
  description = "Subnet the VM resided in"
}

variable "ip_address" {
  type        = string
  default     = ""
  description = "CIDR for the Debian VM"
}

variable "gateway_ip" {
  type        = string
  default     = ""
  description = "Gateway IP for the Debian VM"
}

variable "nameservers" {
  type        = list(string)
  default     = ["1.1.1.1"]
  description = "Nameservers for the Debian VM"
}

variable "ca_certs" {
  type        = string
  description = "CA certificates for the Debian VM"
  default     = []
}

variable "substrates" {
  type = list(object({
    files = list(object({
      path    = string
      content = string
      enabled = optional(bool, true)
      mode    = optional(string, "0644")
      owner   = optional(string, "root")
      group   = optional(string, "root")
    }))
    install = object({
      systemd_units = list(object({
        name    = string
        content = string
      }))
      apt = object({
        repositories = list(string)
        packages     = list(string)
      })
    })
    users = list(object({
      name     = string
      home_dir = string
    }))
  }))
  default     = []
  description = "List of substrate configurations"
}

variable "additional_packages" {
  type    = list(string)
  default = []
}

variable "base64_encode" {
  type        = bool
  default     = false
  description = "Whether to base64 encode the configuration"
}
