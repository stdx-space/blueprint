data "http" "upstream" {
  url = var.supplychain
}

locals {
  pkgs = {
    for pkg in ["vault", "lego"] : pkg => jsondecode(data.http.upstream.response_body).syspkgs[pkg]
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
      path  = "${var.install_dir}/tls.hcl"
      owner = "vault"
      group = "vault"
      content = templatefile(
        "${path.module}/templates/tls.hcl.tftpl",
        {
          domain = var.acme_domain
        }
      )
    },
    {
      path    = "/etc/vault.d/listener.hcl"
      owner   = "vault"
      group   = "vault"
      content = file("${path.module}/templates/listener.hcl.tftpl")
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
          endpoint   = var.s3_endpoint
          bucket     = var.bucket
        }
      )
    },
    {
      path    = "/etc/vault.d/vault.env"
      owner   = "vault"
      group   = "vault"
      content = ""
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
        name = "lego-oneshot.service"
        content = templatefile(
          "${path.module}/templates/lego-oneshot.service.tftpl",
          {
            api_dns_token  = var.cf_dns_token
            api_zone_token = var.cf_zone_token
            domain         = var.acme_domain
            acme_email     = var.acme_email
            install_dir    = var.install_dir
          }
        )
      },
      {
        name = "lego-renewal.service"
        content = templatefile(
          "${path.module}/templates/lego-renewal.service.tftpl",
          {
            api_dns_token  = var.cf_dns_token
            api_zone_token = var.cf_zone_token
            domain         = var.acme_domain
            acme_email     = var.acme_email
          }
        )
      },
      {
        name    = "lego-renewal.timer"
        content = file("${path.module}/templates/lego-renewal.timer.tftpl")
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
        name = "vault-cert-watcher.path"
        content = templatefile(
          "${path.module}/templates/watcher.path.tftpl",
          {
            path    = "/opt/lego/certificates/${var.acme_domain}.crt"
            service = "vault-cert-watcher.service"
          }
        )
      },
      {
        name = "vault-cert-watcher.service"
        content = templatefile("${path.module}/templates/update-certificate.service.tftpl", {
          domain = var.acme_domain
        })
      }
    ]
  )
}
