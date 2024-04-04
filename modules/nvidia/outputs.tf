output "manifest" {
  value = {
    sensitive = false
    users     = local.users
    install = {
      apt           = local.apt
      systemd_units = local.systemd_units
    }
    files = []
  }
}
