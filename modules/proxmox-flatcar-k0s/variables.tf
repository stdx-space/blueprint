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

variable "helm_repositories" {
  type = list(object({
    name = string
    url  = string
  }))
  default = [{
    name = "openebs-internal"
    url  = "https://openebs.github.io/charts"
    },
    {
      name = "traefik"
      url  = "https://traefik.github.io/charts"
    },
    {
      name = "metallb"
      url  = "https://metallb.github.io/metallb"
  }]
}

variable "helm_charts" {
  type = list(object({
    name      = string
    chartname = string
    version   = string
    order     = optional(number)
    values    = string
    namespace = string
  }))
  default = [{
    name      = "openebs"
    chartname = "openebs-internal/openebs"
    version   = "3.9.0"
    order     = 1
    values = yamlencode({
      localprovisioner = {
        hostpathClass = {
          enabled        = true
          isDefaultClass = true
        }
      }
    })
    namespace = "openebs"
    },
    {
      name      = "traefik"
      chartname = "traefik/traefik"
      version   = "30.0.2"
      order     = 2
      namespace = "default"
    },
    {
      name      = "metallb"
      chartname = "metallb/metallb"
      version   = "0.14.8"
      namespace = "default"
      order     = 3
  }]
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "The list of ssh public keys to be added to the authorized_keys file"
  default     = []
}

variable "ssh_keys_import" {
  type        = list(string)
  description = "The list of ssh keys to be imported"
  default     = []
}

variable "node" {
  type        = string
  description = "The node name"
}

variable "storage_pool" {
  type        = string
  description = "The storage pool"
  default     = "local-lvm"
}

variable "flatcar_image_id" {
  type        = string
  description = "The ID of the Flatcar image"
}

locals {
  k0s_config = yamlencode({
    apiVersion = "k0s.k0sproject.io/v1beta1",
    kind       = "ClusterConfig",
    metadata = {
      name = var.name
    },
    spec = {
      api = {
        extraArgs = {
          "anonymous-auth" = "true"
        }
      }
      extensions = {
        helm = {
          charts       = var.helm_charts
          repositories = var.helm_repositories
        }
      }
      network = {
        provider = "calico"
      }
      telemetry = {
        enabled = false
      }
    }
  })
}
