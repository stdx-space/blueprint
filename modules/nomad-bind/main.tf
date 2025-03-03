resource "random_bytes" "secret" {
  length = 32
}

resource "nomad_variable" "secrets" {
  path = "nomad/jobs/${job_name}"
  items = {
    tsig_secret_key   = random_bytes.secret.base64
    tailscale_authkey = var.tailscale_authkey
  }
}

resource "nomad_job" "bind" {
  jobspec = templatefile("${path.module}/bind.nomad.tftpl", {
    bind_version         = var.bind_version
    tailscale_version    = var.tailscale_version
    tailscale_authkey    = var.tailscale_authkey
    zones                = var.zones
    upstream_nameservers = var.upstream_nameservers
    secret               = random_bytes.secret.base64
    resources            = var.resources
  })
  purge_on_destroy = var.purge_on_destroy
}
