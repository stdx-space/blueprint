# Terraform substrate module for NVIDIA GPU on Debian

### Usage

```hcl
module "nvidia" {
  source = "git::https://gitlab.com/narwhl/wip/blueprint.git//modules/nvidia"
}

module "debian" {
  source = "git::https://gitlab.com/narwhl/wip/blueprint.git//modules/debian"
  name   = var.name
  substrates = [
    module.nvidia.manifest,
  ]
  ssh_authorized_keys  = var.ssh_authorized_keys
}


module "proxmox" {
  source         = "git::https://gitlab.com/narwhl/wip/blueprint.git//modules/proxmox"
  name           = var.name
  node           = var.node
  firmware       = "uefi" // required for gpu passthrough to work
  vcpus          = 8
  memory         = 8192
  storage_pool   = var.storage_pool
  disk_size      = 64
  os_template_id = var.disk_template_id
  passthrough_devices = ["example_tagged_gpu_mapped_deivce_in_pve"]
  provisioning_config = module.debian.config
}

```
