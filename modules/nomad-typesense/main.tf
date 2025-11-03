locals {
  typesense_api_key  = var.generate_api_key ? random_password.typesense_api_key[0].result : var.typesense_api_key
  nomad_var_template = "{{ with nomadVar `nomad/jobs/${var.job_name}` }}{{ .%s }}{{ end }}"
}

resource "nomad_variable" "typesense" {
  path      = "nomad/jobs/${var.job_name}"
  namespace = var.namespace
  items = {
    typesense_api_key = local.typesense_api_key
  }
}

resource "nomad_job" "typesense" {
  jobspec = templatefile("${path.module}/templates/typesense.nomad.hcl.tftpl", {
    job_name          = var.job_name
    datacenter_name   = var.datacenter_name
    namespace         = var.namespace
    typesense_version = var.typesense_version
    typesense_api_key = format(local.nomad_var_template, "typesense_api_key")
    host_volume_configs = var.host_volume_config != null ? [
      {
        source    = var.host_volume_config.source
        read_only = var.host_volume_config.read_only
      }
    ] : []
    ephemeral_disk_configs = var.enable_ephemeral_disk ? [{}] : []
    resources              = var.resources
  })
  purge_on_destroy = var.purge_on_destroy
  depends_on       = [nomad_variable.typesense]
}
