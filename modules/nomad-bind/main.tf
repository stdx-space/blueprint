resource "random_bytes" "secret" {
  length = 32
}

resource "nomad_variable" "secrets" {
  path = "nomad/jobs/${var.job_name}"
  items = {
    tsig_secret_key   = random_bytes.secret.base64
    tailscale_authkey = var.tailscale_oauth_client_secret
  }
}

resource "nomad_job" "bind" {
  jobspec = templatefile("${path.module}/templates/bind.nomad.hcl.tftpl", {
    job_name             = var.job_name
    datacenter_name      = var.datacenter_name
    namespace            = var.namespace
    bind_version         = var.bind_version
    tailscale_version    = var.tailscale_version
    tailscale_device_tag = var.tailscale_device_tag
    zones                = var.zones
    upstream_nameservers = var.upstream_nameservers
    resources            = var.resources
    split_dns_vars = yamlencode({
      tailscale_client_id     = var.tailscale_oauth_client_id
      tailscale_client_secret = var.tailscale_oauth_client_secret
    })
    split_dns_provisioner = templatefile("${path.module}/templates/playbook.yml", {
      domain = ".internal"
    })
    secret_key = templatefile("${path.module}/templates/named.conf.key.tftpl", {
      job_name  = var.job_name
      name      = var.tsig_key_name
      algorithm = var.tsig_algorithm
    })
    zone_files = [for z in var.zones : {
      name = z
      content = templatefile(
        "${path.module}/templates/zonefile.tftpl",
        {
          date = formatdate("YYYYMMDD", timestamp())
          zone = z
        }
      )
    }]
    config = templatefile("${path.module}/templates/named.conf.tftpl", {
      zones                = var.zones
      upstream_nameservers = var.upstream_nameservers
    })
  })
  purge_on_destroy = var.purge_on_destroy
}
