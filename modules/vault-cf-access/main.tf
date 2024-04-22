data "http" "github_organization" {
  url = "https://api.github.com/orgs/${var.github_organization}"
}

data "http" "dns_query" {
  url = format(
    "https://cloudflare-dns.com/dns-query?name=%s",
    var.request_origin_ip_domain
  )
  request_headers = {
    Accept = "application/dns-json"
  }
}

data "cloudflare_zone" "this" {
  name = var.zone
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
  min_days_for_renewal = 7
  requested_validity   = 90
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
}

resource "cloudflare_access_policy" "bastion" {
  zone_id        = data.cloudflare_zone.this.id
  application_id = cloudflare_access_application.vault.id
  name           = "Bastion access to Vault"
  decision       = "bypass"
  precedence     = 1
  include {
    ip_list = [
      for record in jsondecode(data.http.dns_query.response_body)["Answer"] : "${record.data}/32"
    ]
  }
}

resource "cloudflare_access_policy" "service_token" {
  zone_id        = data.cloudflare_zone.this.id
  application_id = cloudflare_access_application.vault.id
  name           = "Service token access to Vault"
  decision       = "allow"
  precedence     = 2
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
  precedence     = 3
  include {
    login_method = [data.cloudflare_access_identity_provider.github.name]
  }
  require {
    github {
      identity_provider_id = data.cloudflare_access_identity_provider.github.id
      name                 = var.github_organization
    }
  }
}

resource "terraform_data" "manifest" {
  input = {
    users       = local.users
    directories = local.directories
    packages    = keys(local.pkgs)
    files = concat(
      local.configs,
      [
        for pkg in keys(local.pkgs) : {
          path = format(
            "/etc/extensions/${pkg}-%s-x86-64.raw",
            local.pkgs[pkg].version
          )
          content = format("https://artifact.narwhl.dev/sysext/%s-%s-x86-64.raw", pkg, local.pkgs[pkg].version)
          enabled = true
        }
      ],
      [
        for pkg in keys(local.pkgs) : {
          path = "/etc/sysupdate.${pkg}.d/${pkg}.conf"
          content = templatefile(
            "${path.module}/templates/update.conf.tftpl",
            {
              url     = "https://artifact.narwhl.dev/sysext"
              package = pkg
            }
          )
          enabled = true
        }
      ]
    )
    install = {
      apt           = local.apt
      systemd_units = local.systemd_units
    }
  }
}
