# Terraform substrate module for NVIDIA GPU on Debian

### Usage

```hcl
module "nvidia" {
  source = "registry.narwhl.workers.dev/driver/nvidia/gpu"
}

module "debian" {
  source = "registry.narwhl.workers.dev/os/debian/cloudinit"
  name   = var.name
  substrates = [
    module.nvidia.manifest,
  ]
  ssh_authorized_keys  = var.ssh_authorized_keys
}


module "proxmox" {
  source         = "registry.narwhl.workers.dev/hypervisor/vm/proxmox"
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

## Argument Reference

This module does not require any variable input.

## Outputs

- `manifest`: `(object)`