output "config" {
  value = {
    type    = "cloud-init"
    payload = data.cloudinit_config.user_data.rendered
  }
}

output "files" {
  value = local.files
}
