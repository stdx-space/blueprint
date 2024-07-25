variable "name" {
  type        = string
  description = "The name of the cluster"
}

variable "release" {
  type        = string
  description = "The k0s release version"
}

variable "cluster" {
  type = object({
    worker     = number
    controller = number
    spec = object({
      worker = object({
        cpu       = number
        memory    = number
        disk_size = number
      })
      controller = object({
        cpu       = number
        memory    = number
        disk_size = number
      })
    })
  })
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "The list of ssh public keys to be added to the authorized_keys file"
}

variable "node" {
  type        = string
  description = "The node name"
}

variable "flatcar_image_id" {
  type        = string
  description = "The ID of the Flatcar image"
}
