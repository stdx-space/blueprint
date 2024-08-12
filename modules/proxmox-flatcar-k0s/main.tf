resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "k0s_cluster" "this" {
  name    = var.name
  version = var.release
  config  = local.k0s_config
  hosts = [
    for i in range(var.cluster.controller + var.cluster.worker) : {
      role = i < var.cluster.controller ? "controller+worker" : "worker"
      ssh = {
        address     = module.instance[i].ip_address
        port        = 22
        user        = "core"
        private_key = tls_private_key.this.private_key_pem
      }
    }
  ]
}
