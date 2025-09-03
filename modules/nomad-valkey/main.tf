resource "nomad_dynamic_host_volume" "valkey_data" {
  count = var.dynamic_host_volume_config != null ? 1 : 0

  name         = var.dynamic_host_volume_config.name
  plugin_id    = var.dynamic_host_volume_config.plugin_id
  node_pool    = var.dynamic_host_volume_config.node_pool
  capacity_min = var.dynamic_host_volume_config.capacity_min
  capacity_max = var.dynamic_host_volume_config.capacity_max
  parameters   = var.dynamic_host_volume_config.parameters

  dynamic "capability" {
    for_each = var.dynamic_host_volume_config.capability != null ? [var.dynamic_host_volume_config.capability] : []
    content {
      access_mode     = capability.value.access_mode
      attachment_mode = capability.value.attachment_mode
    }
  }
}

resource "nomad_job" "valkey" {
  jobspec = templatefile("${path.module}/templates/valkey.nomad.hcl.tftpl", {
    job_name        = var.job_name
    datacenter_name = var.datacenter_name
    namespace       = var.namespace
    valkey_version  = var.valkey_version
    # Legacy host volume support (deprecated)
    host_volume_configs = var.host_volume_config != null ? [
      {
        source    = var.host_volume_config.source
        read_only = var.host_volume_config.read_only
      }
    ] : []
    # Dynamic host volume support
    dynamic_host_volume_configs = var.dynamic_host_volume_config != null ? [
      {
        name = var.dynamic_host_volume_config.name
      }
    ] : []
    ephemeral_disk_configs = var.enable_ephemeral_disk ? [{}] : []
    persistent_configs     = var.persistent_config != null ? [var.persistent_config] : []
    resources              = var.resources
  })
  purge_on_destroy = var.purge_on_destroy

  depends_on = [nomad_dynamic_host_volume.valkey_data]
}
