variable "name" {
  type        = string
  description = "Hostname of the Flatcar VM"
  default     = "localhost"
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
  default     = false
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

variable "mounts" {
  type = list(object({
    label     = string
    path      = string
    partition = string
  }))
  default     = []
  description = "List of disk configurations"
}

variable "lvm_volume_groups" {
  type = list(object({
    name    = string
    devices = list(string)
  }))
  default     = []
  description = "List of LVM volume group configurations, e.g [{ name = 'vg0', disks = ['/dev/sda', '/dev/sdb'] }]"
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

variable "expose_metrics" {
  type        = bool
  default     = false
  description = "Whether to enable prometheus node-exporter as system service container"
}

variable "supplychain" {
  type    = string
  default = "https://artifact.narwhl.dev/upstream/current.json"
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
  type = list(string)
  default = [
    "1.1.1.1#cloudflare-dns.com",
    "8.8.8.8#dns.google"
  ]
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
        tags    = optional(string, "ignition")
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
    install = optional(object({
      systemd_units = list(object({
        name    = string
        content = optional(string)
        dropins = optional(map(string), {})
      }))
      repositories = list(string)
      packages     = list(string)
      }), {
      systemd_units = []
      repositories  = []
      packages      = []
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
  default     = []
}

variable "ssh_keys_import" {
  type        = list(string)
  description = "List of URLs to fetch SSH public keys from"
  default     = []
  validation {
    condition     = length(var.ssh_keys_import) == 0 || alltrue([for item in var.ssh_keys_import : startswith(item, "http")])
    error_message = "SSH key import ID must be a valid URL"
  }
}

locals {
  pkgs = {
    for pkg in concat(["alloy"], var.expose_metrics ? ["node-exporter"] : []) : pkg => jsondecode(data.http.upstream.response_body).syspkgs[pkg]
  }
  users = {
    for index, user in concat(
      flatten(var.substrates.*.users),
      var.expose_metrics ? [{ name : "node_exporter", home_dir : "/var/lib/node_exporter" }] : []
      ) : user.name => {
      home_dir = user.home_dir
      uid      = 499 - index
    }
  }
  disks = {
    for mount in var.mounts : mount.partition => mount.label
  }
  permissions = {
    "777" = 495
    "755" = 493
    "700" = 488
    "644" = 420
    "600" = 416
  }
  subnet_bits = 0 < length(var.network) ? split("/", var.network)[1] : "24"
  default_units = concat(
    [
      {
        name = "settimezone.service"
        content = templatefile(
          "${path.module}/templates/settimezone.service.tftpl",
          {
            timezone = var.timezone
          }
        )
      },
    ],
    length(var.lvm_volume_groups) > 0 ? [
      {
        name    = "init-lvm-vg.service"
        content = file("${path.module}/templates/init-lvm-vg.service.tftpl")
      }
    ] : [],
  )
  mount_units = [
    for mount in var.mounts : {
      name = format(
        "%s.mount",
        replace(
          trimprefix(mount.path, "/"),
          "/",
          "-"
        )
      )
      content = templatefile(
        "${path.module}/templates/disk.mount.tftpl",
        {
          label      = mount.label
          mount_path = mount.path
        }
      )
    }
  ]
}
