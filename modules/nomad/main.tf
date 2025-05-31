resource "terraform_data" "manifest" {
  input = {
    directories = local.directories
    packages    = keys(local.pkgs)
    users       = local.users
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
          tags    = "ignition"
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
          tags    = "ignition"
        }
      ],
      [
        for key, item in var.tls.enable ? {
          ca_file   = var.tls.ca_file
          cert_file = var.tls.cert_file
          key_file  = var.tls.key_file
          } : {} : {
          path    = item.path
          content = item.content
          tags    = "cloud-init,ignition"
          enabled = var.tls.enable && length(item.content) > 0
        }
      ]
    )
    install = {
      systemd_units = local.systemd_units
      repositories  = local.repositories
      packages      = local.packages
    }
  }

  lifecycle {
    precondition {
      condition     = var.disable_client || var.role == "server"
      error_message = "Predicate failed due to nomad role cannot be client when disable_client is true"
    }
  }
}
