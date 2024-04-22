resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "nomad_job" "temporal" {
  jobspec = templatefile(
    "${path.module}/templates/temporal.nomad.hcl.tftpl",
    {
      job_name              = var.job_name
      datacenter_name       = var.datacenter_name
      elasticsearch_version = var.elasticsearch_version
      postgres_version      = var.postgres_version
      temporal_version      = var.temporal_version
      temporal_ui_version   = var.temporal_ui_version
      db_password           = random_password.db_password.result
      db_username           = var.postgres_username
    }
  )
  purge_on_destroy = true
}
