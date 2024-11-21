resource "nomad_job" "redis" {
  jobspec = templatefile("${path.module}/templates/redis.nomad.hcl.tftpl", {
    job_name        = var.job_name
    datacenter_name = var.datacenter_name
    redis_version   = var.redis_version
    host_volume_configs = var.host_volume_config != null ? [
      {
        source    = var.host_volume_config.source
        read_only = var.host_volume_config.read_only
      }
    ] : []
    ephemeral_disk_configs = var.enable_ephemeral_disk ? [{}] : []
    persistent_configs = var.persistent_config != null ? [var.persistent_config] : []
  })
  purge_on_destroy = var.purge_on_destroy
}
