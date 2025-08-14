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