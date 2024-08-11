variable "name" {
  type        = string
  description = "Hostname of the Flatcar VM"
  validation {
    condition     = length(var.name) > 0
    error_message = "Instance name must be set"
  }
}

variable "username" {
  type        = string
  default     = "core"
  description = "Login user for the Flatcar VM"
  validation {
    condition     = length(var.username) > 0
    error_message = "Username must be set"
  }
}

variable "autologin" {
  type        = bool
  description = "Whether Flatcar will autologin in console"
  default     = true
}

variable "disable_ssh" {
  type        = bool
  description = "Whether to disable SSH access to the VM"
  default     = false
}

variable "timezone" {
  type        = string
  default     = "Asia/Hong_Kong"
  description = "Timezone of the VM"
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

variable "enable_podman" {
  type        = bool
  default     = false
  description = "Whether to add Podman systemd sysext image during provisioning phase"
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
  description = "CIDR for the VM"
}

variable "gateway_ip" {
  type        = string
  default     = ""
  description = "Gateway IP for the VM"
}

variable "nameservers" {
  type        = list(string)
  default     = ["1.1.1.1"]
  description = "List of nameservers for the VM"
}

variable "ca_certs" {
  type        = list(string)
  default     = []
  description = "List of CA certificates to trust"
}

variable "substrates" {
  type = list(object({
    packages = optional(list(string), [])
    files = optional(
      list(object({
        path    = string
        content = string
        enabled = optional(bool, true)
        mode    = optional(string, "644")
        owner   = optional(string, "root")
        group   = optional(string, "root")
        tags    = string
        })
    ), [])
    directories = optional(
      list(object({
        path  = string
        mode  = optional(string, "755")
        owner = optional(string, "root")
        group = optional(string, "root")
        })
    ), [])
    install = object({
      systemd_units = list(object({
        name    = string
        content = optional(string)
        dropins = optional(map(string), {})
      }))
      repositories = list(string)
      packages     = list(string)
    })
    users = optional(
      list(object({
        name     = string
        home_dir = string
      }))
    , [])
  }))
  default     = []
  description = "List of substrate configurations"
}

variable "base64_encode" {
  type        = bool
  default     = false
  description = "Whether to base64 encode the configuration"
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "List of SSH public keys to add to the VM"
  validation {
    condition     = length(var.ssh_authorized_keys) > 0
    error_message = "At least one SSH public key must be set to prevent locked out"
  }
}

variable "ssh_keys_import" {
  type        = list(string)
  description = "List of URLs to fetch SSH public keys from"
  default     = []
}

locals {
  users = {
    for index, user in flatten(var.substrates.*.users) : user.name => {
      home_dir = user.home_dir
      uid      = 499 - index
    }
  }
  disks = {
    for disk in var.disks : disk.device_path => disk.label
  }
  permissions = {
    "777" = 495
    "755" = 493
    "700" = 488
    "644" = 420
    "600" = 416
  }
  subnet_bits = 0 < length(var.network) ? split("/", var.network)[1] : "24"
  default_units = [
    {
      name = "settimezone.service"
      content = templatefile(
        "${path.module}/templates/settimezone.service.tftpl",
        {
          timezone = var.timezone
        }
      )
    },
    {
      name    = "node-exporter.service"
      content = file("${path.module}/templates/node-exporter.service.tftpl")
    }
  ]
  mount_units = [
    for disk in var.disks : {
      name = format(
        "%s.mount",
        replace(
          trimprefix(disk.mount_path, "/"),
          "/",
          "-"
        )
      )
      content = templatefile(
        "${path.module}/templates/disk.mount.tftpl",
        {
          label      = disk.label
          mount_path = disk.mount_path
        }
      )
    }
  ]
}
