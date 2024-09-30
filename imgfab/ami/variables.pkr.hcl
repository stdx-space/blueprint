variable "vsphere_endpoint" {
  type        = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance."
  default     = env("VSPHERE_SERVER")
}

variable "vsphere_username" {
  type        = string
  description = "The username to login to the vCenter Server instance."
  sensitive   = true
  default     = env("VSPHERE_USER")
}

variable "vsphere_host" {
  type        = string
  description = "The fully qualified domain name or IP address of the ESXi host."
  default     = env("VSPHERE_HOST")
}

variable "vsphere_password" {
  type        = string
  description = "The password for the login to the vCenter Server instance."
  sensitive   = true
  default     = env("VSPHERE_PASSWORD")
}

variable "vsphere_insecure_connection" {
  type        = bool
  description = "Do not validate vCenter Server TLS certificate."
  default     = true
}

// vSphere Settings

variable "vsphere_datacenter" {
  type        = string
  description = "The name of the target vSphere datacenter."
  default     = env("VSPHERE_DATACENTER")
}

variable "vsphere_datastore" {
  type        = string
  description = "The name of the target vSphere datastore."
  default     = env("VSPHERE_DATASTORE")
}

variable "vsphere_network" {
  type        = string
  description = "The name of the target vSphere network segment."
  default     = "VM Network"
}

// Virtual Machine Settings

variable "vm_cpu" {
  type        = number
  description = "The number of virtual CPUs sockets."
  default     = 2
}

variable "vm_mem_size" {
  type        = number
  description = "The size for the virtual memory in MB."
  default     = 2048
}

variable "vm_disk_size" {
  type        = number
  description = "The size for the virtual disk in MB."
  default     = 16384
}

variable "vm_disk_controller_type" {
  type        = list(string)
  description = "The virtual disk controller types in sequence. (e.g. 'pvscsi')"
  default     = ["pvscsi"]
}

variable "vm_disk_thin_provisioned" {
  type        = bool
  description = "Thin provision the virtual disk."
  default     = true
}

variable "vm_network_card" {
  type        = string
  description = "The virtual network card type."
  default     = "vmxnet3"
}

variable "vm_boot_order" {
  type        = string
  description = "Boot order"
  default     = "disk,cdrom"
}

variable "timezone" {
  type    = string
  default = "Asia/Hong_Kong"
}

variable "ssh_username" {
  type      = string
  sensitive = true
  default   = "root"
}

variable "ssh_password" {
  type      = string
  sensitive = true
  default   = "packer"
}

variable "cf_r2_endpoint" {
  type    = string
  default = env("CF_R2_ENDPOINT_URL")
}

variable "cf_r2_access_key_id" {
  type      = string
  sensitive = true
  default   = env("CF_R2_ACCESS_KEY_ID")
}

variable "cf_r2_secret_access_key" {
  type      = string
  sensitive = true
  default   = env("CF_R2_SECRET_ACCESS_KEY")
}