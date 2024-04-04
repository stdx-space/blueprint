data "cloudflare_api_token_permission_groups" "all" {}

data "cloudflare_zone" "this" {
  name = var.dns_zone_name
}

resource "random_id" "tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_tunnel" "ingress" {
  account_id = var.cloudflare_account_id
  name       = "ingress"
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_api_token" "dns_challenge_token" {
  name = "Ephemeral Token for ACME TLS Challenge"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
    ]
    resources = {
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.this.id}" = "*"
    }
  }
}

data "consul_service" "ingress" {
  name       = "${var.controller_job_name}-ingress-controller"
  datacenter = var.datacenter_name

  depends_on = [
    nomad_job.ingress-controller,
    nomad_job.ingress-gateway
  ]
}

data "consul_service" "nomad" {
  name       = "nomad"
  datacenter = var.datacenter_name
}

resource "cloudflare_tunnel_config" "ingress" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.ingress.id

  config {
    ingress_rule {
      service = "http://${data.consul_service.ingress.service[0].address}:${data.consul_service.ingress.service[0].port}"
    }
  }

  depends_on = [data.consul_service.ingress]
}

resource "nomad_job" "ingress-controller" {
  jobspec = templatefile(
    "${path.module}/templates/traefik.nomad.hcl.tftpl",
    {
      job_name        = var.controller_job_name
      datacenter_name = var.datacenter_name
      version         = var.traefik_version
      acme_email      = var.acme_email
      cf_api_token    = cloudflare_api_token.dns_challenge_token.value
      nomad_address   = data.consul_service.nomad.service[0].address
      static_routes   = var.static_routes
    }
  )
}

resource "nomad_job" "ingress-gateway" {
  jobspec = templatefile(
    "${path.module}/templates/cloudflared.nomad.hcl.tftpl",
    {
      job_name        = var.gateway_job_name
      datacenter_name = var.datacenter_name
      version         = var.cloudflared_version
      tunnel_token    = cloudflare_tunnel.ingress.tunnel_token
    }
  )
}
