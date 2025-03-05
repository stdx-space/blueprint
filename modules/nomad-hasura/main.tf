locals {
  nomad_var_template  = "{{ with nomadVar \"nomad/jobs/${var.job_name}\" }}{{ .%s }}{{ end }}"
  hasura_admin_secret = var.hasura_admin_secret == "" ? random_password.hasura_admin_secret[0].result : var.hasura_admin_secret
}

resource "nomad_variable" "hasura" {
  path      = "nomad/jobs/${var.job_name}"
  namespace = var.namespace
  items = {
    db_password         = var.db_password
    hasura_admin_secret = local.hasura_admin_secret
  }
}

resource "nomad_job" "hasura" {
  jobspec = templatefile("${path.module}/templates/hasura.nomad.hcl.tftpl", {
    job_name            = var.job_name
    datacenter_name     = var.datacenter_name
    namespace           = var.namespace
    hasura_version      = var.hasura_version
    db_user             = var.db_username
    db_password         = format(local.nomad_var_template, "db_password")
    db_addr             = var.db_address
    hasura_admin_secret = format(local.nomad_var_template, "hasura_admin_secret")
    resources           = var.resources
  })
  purge_on_destroy = var.purge_on_destroy
}
