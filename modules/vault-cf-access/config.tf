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
  apt = {
    repositories = [
      "hashicorp"
    ]
    packages = [
      "vault",
    ]
  }
}

locals {
  configs = [
    {
      path    = "/etc/sysctl.d/00-sysctl.conf"
      content = file("${path.module}/templates/sysctl.conf.tftpl")
    },
    {
      path    = "/etc/security/limits.conf"
      content = file("${path.module}/templates/limits.conf.tftpl")
    },
    {
      path    = "/etc/systemd/coredump.conf.d/disable.conf"
      content = file("${path.module}/templates/disable-coredump.conf.tftpl")
    },
    {
      path    = "/etc/profile.d/ulimit.sh"
      content = file("${path.module}/templates/ulimits.sh.tftpl")
    },
    {
      path    = "/etc/profile.d/vault.sh"
      content = file("${path.module}/templates/vault.sh.tftpl")
      mode    = "755"
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
    },
    {
      path  = "/etc/vault.d/config.hcl"
      owner = "vault"
      group = "vault"
      content = templatefile(
        "${path.module}/templates/config.hcl.tftpl",
        {
          log_level  = var.log_level
          access_key = var.access_key
          secret_key = var.secret_key
          endpoint   = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
          bucket     = var.bucket
        }
      )
    },
    {
      path    = "/etc/vault.d/vault.env"
      owner   = "vault"
      group   = "vault"
      content = ""
    },
    {
      path    = "/opt/vault/tls/vault.${var.zone}.key"
      owner   = "vault"
      group   = "vault"
      content = tls_private_key.vault.private_key_pem
    },
    {
      path    = "/opt/vault/tls/vault.${var.zone}.crt"
      owner   = "vault"
      group   = "vault"
      content = cloudflare_origin_ca_certificate.vault.certificate
    },
    {
      path = "/etc/default/cloudflared"
      content = format(
        "CLOUDFLARED_OPTS=tunnel --no-autoupdate run --token %s",
        base64encode(jsonencode({
          "a" = var.cloudflare_account_id,
          "t" = cloudflare_tunnel.vault.id,
          "s" = base64sha256(random_password.tunnel_secret.result)
        }))
      )
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
  systemd_units = concat(
    [
      {
        name    = "cloudflared.service"
        content = file("${path.module}/templates/cloudflared.service.tftpl")
      },
    ],
    [
      for pkg in keys(local.pkgs) : {
        name = "${pkg}-sysext-img-watcher.path"
        content = templatefile(
          "${path.module}/templates/watcher.path.tftpl",
          {
            path = format(
              "/etc/extensions/${pkg}-%s-x86-64.raw",
              local.pkgs[pkg].version
            )
            service = "sysext-img-refresh.service"
          }
        )
      }
    ],
    [
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
  )
}
