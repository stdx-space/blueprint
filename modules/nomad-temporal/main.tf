locals {
  nomad_var_template = "{{ with nomadVar \"nomad/jobs/${var.job_name}\" }}{{ .%s }}{{ end }}"
}

resource "nomad_variable" "temporal" {
  path = "nomad/jobs/${var.job_name}"
  items = {
    db_password = var.postgres_password
  }
}

resource "nomad_job" "temporal" {
  jobspec = templatefile(
    "${path.module}/templates/temporal.nomad.hcl.tftpl",
    {
      job_name            = var.job_name
      service_name        = var.service_name
      datacenter_name     = var.datacenter_name
      namespace           = var.namespace
      temporal_version    = var.temporal_version
      temporal_ui_version = var.temporal_ui_version
      db_password         = format(local.nomad_var_template, "db_password")
      db_user             = var.postgres_username
      db_host             = var.postgres_host
      db_port             = var.postgres_port
      db_name             = var.postgres_database
      visibility_db_name  = var.postgres_visibility_database
    }
  )
  purge_on_destroy = var.purge_on_destroy
}
