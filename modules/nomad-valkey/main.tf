resource "nomad_job" "valkey" {
  jobspec = templatefile("${path.module}/templates/valkey.nomad.hcl.tftpl", {
    job_name        = var.job_name
    datacenter_name = var.datacenter_name
    namespace       = var.namespace
    valkey_version  = var.valkey_version
    host_volume_configs = var.host_volume_config != null ? [
      {
        source    = var.host_volume_config.source
        read_only = var.host_volume_config.read_only
      }
    ] : []
    ephemeral_disk_configs = var.enable_ephemeral_disk ? [{}] : []
    persistent_configs     = var.persistent_config != null ? [var.persistent_config] : []
    resources              = var.resources
  })
  purge_on_destroy = var.purge_on_destroy
}
