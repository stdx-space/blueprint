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
    storage_id       = string
    size             = number
    thin_provisioned = bool
  }))
  default     = []
  description = "List of disks to attach to the compute instance"
}

variable "networks" {
  type = list(object({
    id = string
  }))
  description = "List of networks to attach to the compute instance"
  default = [
    {
      id = "VM Network"
    }
  ]
  validation {
    condition     = length(var.networks) > 0
    error_message = "At least one network must be specified"
  }
}

variable "firmware" {
  type        = string
  default     = "bios"
  description = "Firmware variant to use upon booting for the compute instance"
}

# vSphere specific variables

variable "host" {
  type        = string
  description = "vSphere host that runs the compute instance"
}

variable "resource_pool_id" {
  type        = string
  description = "vSphere resource pool"
}

variable "datacenter" {
  type        = string
  description = "vSphere datacenter that the compute instance's host is a part of"
}

variable "datastore" {
  type        = string
  description = "vSphere datastore that the compute instance's virtual disk is located on"
  default     = "datastore1"
  validation {
    condition     = length(var.datastore) > 0
    error_message = "Datastore must be specified"
  }
}

variable "os_template_id" {
  type        = string
  description = "vSphere template that the compute instance will be based on"
  validation {
    condition     = length(var.os_template_id) > 0
    error_message = "OS template must be specified"
  }
}

variable "wait_for_guest_ip_timeout" {
  type    = number
  default = 0
}

variable "wait_for_guest_net_routable" {
  type    = bool
  default = false
}

# Local variables

locals {
  disks = length(var.disks) > 0 ? var.disks : [
    {
      storage_id       = data.vsphere_datastore.this.id
      size             = var.disk_size
      thin_provisioned = true
    }
  ]
  networks = {
    for network in var.networks : network.id => network.id
  }
  vapp = {
    "cloud-init" = {}
    "ignition"   = toset([var.provisioning_config.type])
    "talos"      = {}
  }[var.provisioning_config.type]
  extra_config = {
    "cloud-init" = {
      "guestinfo.userdata"          = base64encode(var.provisioning_config.payload)
      "guestinfo.userdata.encoding" = "gzip+base64"
    }
    "ignition" = {
      "guestinfo.ignition.config.data"          = base64encode(var.provisioning_config.payload)
      "guestinfo.ignition.config.data.encoding" = "base64"
    }
    "talos" = {
      "guestinfo.talos.config" = base64encode(var.provisioning_config.payload)
    }
  }[var.provisioning_config.type]
}
