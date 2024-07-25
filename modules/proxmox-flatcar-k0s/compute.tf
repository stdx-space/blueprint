module "flatcar" {
  count               = var.cluster.controller + var.cluster.worker
  source              = "github.com/narwhl/blueprint//modules/flatcar"
  name                = count.index < var.cluster.controller ? "k0s-controller-${count.index}" : "k0s-worker-${count.index - var.cluster.controller}"
  ssh_authorized_keys = concat(var.ssh_authorized_keys, tls_private_key.this.public_key_pem)
}

module "instance" {
  count               = var.cluster.controller + var.cluster.worker
  source              = "github.com/narwhl/blueprint//modules/proxmox"
  node                = var.node
  vcpus               = count.index < var.cluster.controller ? var.cluster.spec.controller.cpu : var.cluster.spec.worker.cpu
  memory              = count.index < var.cluster.controller ? var.cluster.spec.controller.memory : var.cluster.spec.worker.memory
  disk_size           = count.index < var.cluster.controller ? var.cluster.spec.controller.disk_size : var.cluster.spec.worker.disk_size
  os_template         = var.flatcar_image_id
  provisioning_config = module.flatcar.config
}
