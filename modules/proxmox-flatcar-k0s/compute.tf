module "flatcar" {
  count               = var.cluster.controller + var.cluster.worker
  source              = "github.com/narwhl/blueprint//modules/flatcar"
  name                = count.index < var.cluster.controller ? "k0s-cp-${count.index}" : "k0s-worker-${count.index - var.cluster.controller}"
  ssh_authorized_keys = concat(var.ssh_authorized_keys, [tls_private_key.this.public_key_pem])
  ssh_keys_import     = var.ssh_keys_import
  substrates = [
    {
      directories = [
        {
          path = "/var/lib/k0s/manifests/oidc-reviewer"
        },
      ]
      files = [
        {
          path = "/var/lib/k0s/manifests/oidc-reviewer/oidc-reviewer.yaml"
          content = yamlencode({
            apiVersion = "rbac.authorization.k8s.io/v1"
            kind       = "ClusterRoleBinding"
            metadata = {
              name = "oidc-reviewer"
            }
            roleRef = {
              apiGroup = "rbac.authorization.k8s.io"
              kind     = "ClusterRole"
              name     = "system:service-account-issuer-discovery"
            }
            subjects = [
              {
                kind = "Group"
                name = "system:unauthenticated"
              }
            ]
          })
        },
      ]
    }
  ]
}

module "instance" {
  count               = var.cluster.controller + var.cluster.worker
  source              = "github.com/narwhl/blueprint//modules/proxmox"
  name                = count.index < var.cluster.controller ? "k0s-cp-${count.index}" : "k0s-worker-${count.index - var.cluster.controller}"
  node                = var.node
  vcpus               = count.index < var.cluster.controller ? var.cluster.spec.controller.cpu : var.cluster.spec.worker.cpu
  memory              = count.index < var.cluster.controller ? var.cluster.spec.controller.memory : var.cluster.spec.worker.memory
  disk_size           = count.index < var.cluster.controller ? var.cluster.spec.controller.disk_size : var.cluster.spec.worker.disk_size
  os_template_id      = var.flatcar_image_id
  storage_pool        = var.storage_pool
  provisioning_config = module.flatcar[count.index].config
}
