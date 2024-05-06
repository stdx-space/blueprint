# General info for the compute instance

variable "name" {
  type        = string
  description = "Name of the compute instance"
  validation {
    condition     = length(var.name) > 0
    error_message = "Instance name must be specified"
  }
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "List of tags to apply to the compute instance"
}

variable "provisioning_config" {
  type = object({
    type    = string
    payload = string
  })
  description = "Either be cloud-init user-data or ignition config"
}

variable "network_data_config" {
  type    = string
  default = ""
}

variable "meta_data_config" {
  type    = string
  default = ""
}

# Resource specifications

variable "vcpus" {
  type        = number
  default     = 1
  description = "Number of vCPU cores to allocate to the compute instance"
  validation {
    condition     = tonumber(var.vcpus) == floor(var.vcpus)
    error_message = "vCPU count must be an integer"
  }
  validation {
    condition     = var.vcpus > 0
    error_message = "vCPU count must be greater than zero"
  }
}

variable "memory" {
  type        = number
  default     = 512
  description = "Amount of memory (MB) to allocate to the compute instance"
  validation {
    condition     = var.memory > 512
    error_message = "Memory must be greater than 512 MB"
  }
}

variable "disk_size" {
  type        = number
  description = "Size of disk in GB allocated to the compute instance"
  default     = 16
  validation {
    condition     = var.disk_size > 8
    error_message = "Disk size must be greater than 8 GB"
  }
}

variable "disks" {
  type = list(object({
    storage_id       = optional(string)
    size             = number
    thin_provisioned = optional(bool)
  }))
  default     = []
  description = "List of disks to attach to the compute instance"
}

variable "networks" {
  type = list(object({
    id = string
  }))
  default = [
    {
      id = "vmbr0"
    }
  ]
  description = "List of networks to attach to the compute instance"
  validation {
    condition     = length(var.networks) > 0
    error_message = "At least one network must be specified"
  }
}

variable "mounting_iso" {
  type    = string
  default = ""
}

variable "firmware" {
  type        = string
  default     = "bios"
  description = "Firmware variant to use upon booting for the compute instance"

  validation {
    condition     = var.firmware == "bios" || var.firmware == "uefi"
    error_message = "Invalid value for firmware, must be either 'bios' or 'uefi'"
  }
}

# Proxmox specific variables

variable "node" {
  type        = string
  default     = "pve"
  description = "Name of the Proxmox node to create the compute instance on"
  validation {
    condition     = length(var.node) > 0
    error_message = "Node name must be specified"
  }
}

variable "storage_pool" {
  type        = string
  description = "Name of the storage pool to create the compute instance on"
  default     = "local-lvm"
  validation {
    condition     = length(var.storage_pool) > 0
    error_message = "Storage pool name must be specified"
  }
}

variable "snippet_stored_path" {
  type        = string
  default     = "/var/lib/vz/snippets"
  description = "Filesystem path to store the snippets in Proxmox"
}

variable "qemu_agent_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable the QEMU agent on the compute instance"
}

variable "os_template_id" {
  type        = string
  description = "ID of the OS template to use for the compute instance"
  validation {
    condition     = length(var.os_template_id) > 0
    error_message = "OS template ID must be specified"
  }
}

variable "passthrough_devices" {
  type        = list(string)
  default     = []
  description = "List of mapped host devices to pass through to the compute instance"
}

# Local variables

locals {
  disks = length(var.disks) > 0 ? [
    for disk in var.disks : {
      storage_id       = contains(keys(disk), "storage_id") ? disk.storage_id : var.storage_pool
      size             = disk.size
      thin_provisioned = disk.thin_provisioned ? "on" : "ignore"
    }
    ] : [
    {
      storage_id       = var.storage_pool
      size             = var.disk_size
      thin_provisioned = "on"
    }
  ]

  kvm_arguments = {
    "ignition" = format(
      "-fw_cfg name=opt/org.flatcar-linux/config,file=%s/%s.ign",
      var.snippet_stored_path,
      sha256(var.provisioning_config.payload)
    )
    "cloud-init" = ""
  }[var.provisioning_config.type]

  provisioning_config_file_format = {
    "ignition"   = "ign"
    "cloud-init" = "yaml"
    "talos"      = "yml"
  }[var.provisioning_config.type]

  cdrom = length(var.mounting_iso) > 0 ? {
    file_id = var.mounting_iso
  } : {}

  efi_disk = {
    "bios" = {}
    "uefi" = { "firmware" = "uefi" }
  }[var.firmware]

  initialization = {
    "ignition"   = {}
    "cloud-init" = { "${var.provisioning_config.type}" = "" }
  }[var.provisioning_config.type]

  cloudinit_drive_interface = {
    "bios" = "ide2"
    "uefi" = "scsi1"
  }

  machine = {
    "bios" = "pc"
    "uefi" = "q35"
  }[var.firmware]

  boot_mode = {
    "bios" = "seabios"
    "uefi" = "ovmf"
  }[var.firmware]
}
