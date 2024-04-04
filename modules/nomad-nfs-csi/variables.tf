variable "plugin_id" {
  type        = string
  default     = "nfs0"
  description = "The ID of the plugin"
  validation {
    condition     = length(var.plugin_id) > 0
    error_message = "The plugin ID must be set"
  }
}

variable "datacenter_name" {
  type        = string
  description = "The name of the nomad datacenter"
  default     = "dc1"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "The datacenter name must be set"
  }
}

variable "nfs_csi_driver_version" {
  type        = string
  default     = "v4.5.0"
  description = "Version of CSI driver to use for NFS, from https://github.com/kubernetes-csi/csi-driver-nfs/releases/"
}

variable "nfs_server_address" {
  type        = string
  description = "The DNS name or IP address of the NFS server"
}

variable "nfs_share_name" {
  type        = string
  description = "The name of the NFS share"
}

variable "volumes" {
  type = list(object({
    name        = string
    directory   = string
    permissions = string
  }))
  description = "The list of volumes to mount"
  default     = []
}

locals {
  volumes = {
    for volume in var.volumes : volume.name => volume
  }
}
