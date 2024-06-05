data "http" "upstream" {
  url = var.supplychain
}

locals {
  pkgs = {
    for pkg in ["vault", "cloudflared"] : pkg => jsondecode(data.http.upstream.response_body).syspkgs[pkg]
  }
}

locals {
  users = [
    {
      name     = "vault"
      home_dir = var.data_dir
    }
  ]
}

locals {
  configs = [
    {
      path    = "/etc/sysctl.d/00-sysctl.conf"
      content = file("${path.module}/templates/sysctl.conf.tftpl")
      tags    = "cloud-init,ignition"
    },
    {
      path    = "/etc/security/limits.conf"
      content = file("${path.module}/templates/limits.conf.tftpl")
      tags    = "cloud-init,ignition"
    },
    {
      path    = "/etc/systemd/coredump.conf.d/disable.conf"
      content = file("${path.module}/templates/disable-coredump.conf.tftpl")
      tags    = "cloud-init,ignition"
    },
    {
      path    = "/etc/profile.d/ulimit.sh"
      content = file("${path.module}/templates/ulimits.sh.tftpl")
      tags    = "cloud-init,ignition"
    },
    {
      path    = "/etc/profile.d/vault.sh"
      content = file("${path.module}/templates/vault.sh.tftpl")
      mode    = "755"
      tags    = "cloud-init,ignition"
    },
    {
      path  = "/etc/vault.d/listener.hcl"
      owner = "vault"
      group = "vault"
      content = templatefile(
        "${path.module}/templates/tls.hcl.tftpl",
        {
          domain = "vault.${var.zone}"
        }
      )
      tags = "cloud-init,ignition"
    },
    {
      path  = "/etc/vault.d/config.hcl"
      owner = "vault"
      group = "vault"
      content = templatefile(
        "${path.module}/templates/config.hcl.tftpl",
        {
          log_level = var.log_level
        }
      )
      tags = "cloud-init,ignition"
    },
    {
      path  = "/opt/backend.hcl"
      owner = "root"
      group = "root"
      content = templatefile(
        "${path.module}/templates/backend.hcl.tftpl",
        {
          access_key = var.access_key
          secret_key = var.secret_key
          endpoint   = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
          bucket     = var.bucket
        }
      )
      tags = "cloud-init,ignition"
    },
    {
      path  = "/opt/tunnel-token"
      owner = "root"
      group = "root"
      content = base64encode(jsonencode({
        "a" = var.cloudflare_account_id,
        "t" = cloudflare_tunnel.vault.id,
        "s" = base64sha256(random_password.tunnel_secret.result)
      }))
      tags = "cloud-init,ignition"
    },
    {
      path    = "/etc/vault.d/vault.env"
      owner   = "vault"
      group   = "vault"
      content = ""
      tags    = "cloud-init,ignition"
    },
    {
      path    = "/opt/vault/tls/vault.${var.zone}.key"
      owner   = "vault"
      group   = "vault"
      content = tls_private_key.vault.private_key_pem
      tags    = "cloud-init,ignition"
    },
    {
      path    = "/opt/vault/tls/vault.${var.zone}.crt"
      owner   = "vault"
      group   = "vault"
      content = cloudflare_origin_ca_certificate.vault.certificate
      tags    = "cloud-init,ignition"
    },
    {
      path    = "/etc/default/cloudflared"
      content = "CLOUDFLARED_OPTS=tunnel --no-autoupdate run"
      tags    = "cloud-init,ignition"
    }
  ]
  directories = [
    {
      path  = "/etc/vault.d"
      owner = "vault"
      group = "vault"
    },
    {
      path  = "/opt/vault"
      owner = "vault"
      group = "vault"
    },
    {
      path  = "/opt/vault/data"
      owner = "vault"
      group = "vault"
    },
    {
      path  = "/opt/vault/tls"
      owner = "vault"
      group = "vault"
    },
  ]
  systemd_units = [
    {
      name    = "seal-credentials.service"
      content = file("${path.module}/templates/seal-credentials.service.tftpl")
    },
    {
      name    = "cloudflared.service"
      content = file("${path.module}/templates/cloudflared.service.tftpl")
      dropins = {
        "tunnel-token.conf" = <<-EOF
            [Service]
            ExecStart=
            ExecStart=/bin/bash -c '/usr/bin/cloudflared $CLOUDFLARED_OPTS --token $(cat $${CREDENTIALS_DIRECTORY}/tunnel-token)' 
          EOF
      }
    },
    {
      name    = "vault.service"
      content = null
      dropins = {
        "backend.conf" = <<-EOF
          [Service]
          ExecStart=
          ExecStart=/usr/bin/vault server -config=/etc/vault.d -config=$${CREDENTIALS_DIRECTORY}/vault-s3-backend
        EOF
      }
    },
    {
      name = "vault-watcher.service"
      content = templatefile(
        "${path.module}/templates/restarter.service.tftpl", {
          package = "vault"
          service = "vault"
        }
      )
    },
    {
      name = "vault-watcher.path"
      content = templatefile(
        "${path.module}/templates/watcher.path.tftpl",
        {
          path    = "/usr/bin/vault"
          service = "vault-watcher.service"
        }
      )
    },
    {
      name    = "vault-sidecar.timer"
      content = file("${path.module}/templates/vault-sidecar.timer.tftpl")
    },
    {
      name = "vault-sidecar.service"
      content = templatefile(
        "${path.module}/templates/vault-sidecar.service.tftpl",
        {
          webhook_url = var.webhook_url
        }
      )
    },
  ]
}
