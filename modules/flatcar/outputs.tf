output "config" {
  value = {
    type    = "ignition"
    payload = var.base64_encode ? base64encode(data.ignition_config.config.rendered) : data.ignition_config.config.rendered
  }
}
