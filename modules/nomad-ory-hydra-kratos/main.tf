resource "random_bytes" "kratos_secret_cipher" {
  length = 16
}

resource "random_bytes" "kratos_cookie_secret" {
  length = 16
}

resource "random_bytes" "hydra_cookie_secret" {
  length = 16
}

resource "random_bytes" "hydra_system_secret" {
  length = 8
}

resource "random_bytes" "hydra_oidc_pairwise_salt" {
  length = 8
}

resource "nomad_job" "hydra-kratos" {
  jobspec = templatefile(
    "${path.module}/templates/jobspec.nomad.hcl.tftpl",
    {
      job_name           = var.job_name
      datacenter_name    = var.datacenter_name
      db_user            = var.database_user
      db_password        = var.database_password
      db_addr            = var.database_addr
      db_sslmode         = var.database_sslmode
      hydra_db_name      = var.hydra_db_name
      kratos_db_name     = var.kratos_db_name
      hydra_version      = var.hydra_version
      kratos_version     = var.kratos_version
      hydra_config       = local.hydra_config
      hydra_public_fqdn  = local.hydra_fqdn
      kratos_config      = local.kratos_config
      kratos_public_fqdn = local.kratos_public_fqdn
    }
  )
}
