data "http" "github_organization" {
  url = "https://api.github.com/orgs/${var.github_organization}"
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
      repositories = [
        "hashicorp"
      ]
      packages = [
        "vault",
      ]
      systemd_units = local.systemd_units
    }
  }
}
