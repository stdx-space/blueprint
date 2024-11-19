locals {
  typesense_api_key = var.typesense_api_key == "" ? random_password.typesense_api_key[0].result : var.typesense_api_key
}

resource "nomad_job" "typesense" {
  jobspec = templatefile("${path.module}/templates/typesense.nomad.hcl.tftpl", {
    job_name          = var.job_name
    datacenter_name   = var.datacenter_name
    typesense_version = var.typesense_version
    typesense_api_key = var.typesense_api_key
    host_volume_configs = var.host_volume_config != null ? [
      {
        source    = var.host_volume_config.source
        read_only = var.host_volume_config.read_only
      }
    ] : []
    ephemeral_disk_configs = var.enable_ephemeral_disk ? [{}] : []
  })
  purge_on_destroy = var.purge_on_destroy
}
