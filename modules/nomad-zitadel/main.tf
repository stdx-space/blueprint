resource "nomad_job" "zitadel" {
  jobspec = templatefile("${path.module}/templates/zitadel.nomad.hcl.tftpl", {
    job_name                = var.job_name
    datacenter_name         = var.datacenter_name
    namespace               = var.namespace
    zitadel_version         = var.zitadel_version
    external_domain         = var.external_domain
    postgres_host           = var.postgres_host
    postgres_port           = var.postgres_port
    postgres_database       = var.postgres_database
    postgres_username       = var.postgres_username
    postgres_password       = var.postgres_password
    postgres_ssl_mode       = var.postgres_ssl_mode
    postgres_admin_username = var.postgres_admin_username
    postgres_admin_password = var.postgres_admin_password
    traefik_entrypoint      = var.traefik_entrypoint
    organization_name       = var.organization_name
    root_username           = var.root_username
    root_password           = local.root_password
    masterkey               = local.masterkey
    resources               = var.resources
  })
  purge_on_destroy = var.purge_on_destroy
}