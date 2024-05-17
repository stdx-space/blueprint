data "cloudflare_zone" "this" {
  name = var.zone
}

data "http" "dns_query" {
  for_each = toset(var.request_origin_ip_domain)
  url = format(
    "https://cloudflare-dns.com/dns-query?name=%s",
    each.key
  )
  request_headers = {
    Accept = "application/dns-json"
  }
}

data "cloudflare_access_identity_provider" "github" {
  zone_id = data.cloudflare_zone.this.id
  name    = "GitHub"
}

resource "tls_private_key" "vault" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "vault" {
  private_key_pem = tls_private_key.vault.private_key_pem
  subject {
    common_name  = "vault.${var.zone}"
    organization = jsondecode(data.http.github_organization.response_body)["name"]
  }
}

resource "cloudflare_origin_ca_certificate" "vault" {
  csr                  = tls_cert_request.vault.cert_request_pem
  hostnames            = ["vault.${var.zone}"]
  request_type         = "origin-ecc"
  min_days_for_renewal = var.min_days_for_renewal
  requested_validity   = var.cf_origin_ca_cert_ttl
}

resource "random_password" "tunnel_secret" {
  length = 64
}

resource "cloudflare_tunnel" "vault" {
  account_id = var.cloudflare_account_id
  name       = "Vault Tunnel"
  secret     = base64sha256(random_password.tunnel_secret.result)
}

resource "cloudflare_record" "vault" {
  zone_id = data.cloudflare_zone.this.id
  name    = "vault"
  value   = cloudflare_tunnel.vault.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_tunnel_config" "vault" {
  tunnel_id  = cloudflare_tunnel.vault.id
  account_id = var.cloudflare_account_id
  config {
    ingress_rule {
      hostname = cloudflare_record.vault.hostname
      service  = "https://127.0.0.1:8200"
      origin_request {
        origin_server_name = "vault.${var.zone}"
      }
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_access_application" "vault" {
  zone_id          = data.cloudflare_zone.this.id
  name             = "Vault"
  domain           = "vault.${var.zone}"
  session_duration = "1h"

  allowed_idps = [
    data.cloudflare_access_identity_provider.github.id,
  ]

  auto_redirect_to_identity = true
}

resource "cloudflare_access_policy" "bastion" {
  zone_id        = data.cloudflare_zone.this.id
  application_id = cloudflare_access_application.vault.id
  name           = "Bastion access to Vault"
  decision       = "bypass"
  precedence     = 3
  include {
    ip = [
      for record in flatten(
        [
          for key in keys(data.http.dns_query) : jsondecode(data.http.dns_query[key].response_body).Answer
        ]
      ) : "${record.data}/32"
    ]
  }
}

resource "cloudflare_access_policy" "service_token" {
  zone_id        = data.cloudflare_zone.this.id
  application_id = cloudflare_access_application.vault.id
  name           = "Service token access to Vault"
  decision       = "non_identity"
  precedence     = 1
  include {
    service_token = [
      var.cloudflare_access_service_token_id
    ]
  }
}

resource "cloudflare_access_policy" "remote" {
  zone_id        = data.cloudflare_zone.this.id
  application_id = cloudflare_access_application.vault.id
  name           = "Remote access to Vault"
  decision       = "allow"
  precedence     = 2
  include {
    login_method = [data.cloudflare_access_identity_provider.github.id]
  }
  require {
    github {
      identity_provider_id = data.cloudflare_access_identity_provider.github.id
      name                 = var.github_organization
    }
  }
}
