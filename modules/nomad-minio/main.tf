locals {
  minio_superuser_password = var.minio_superuser_password == "" ? random_password.superuser_password[0].result : var.minio_superuser_password
}

resource "nomad_job" "minio" {
  jobspec = templatefile("${path.module}/templates/minio.nomad.hcl.tftpl", {
    job_name        = var.job_name
    datacenter_name = var.datacenter_name
    minio_hostname  = var.minio_hostname
    minio_user      = var.minio_superuser_name
    minio_password  = local.minio_superuser_password
    host_volume_configs = var.host_volume_config != null ? [
      {
        source    = var.host_volume_config.source
        read_only = var.host_volume_config.read_only
      }
    ] : []
    resources                      = var.resources
    consul_service_configs         = var.service_discovery_provider == "consul" ? [{}] : []
    consul_connect_service_configs = var.service_discovery_provider == "consul-connect" ? [{}] : []
    nomad_service_configs          = var.service_discovery_provider == "nomad" ? [{}] : []
    https_configs                  = var.enable_https ? [{}] : []
  })
  purge_on_destroy = var.purge_on_destroy
}
