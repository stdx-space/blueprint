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

resource "random_password" "kratos_db_password" {
  count = var.kratos_database_password == "" ? 1 : 0
  # count = 0
  length  = 32
  special = false
}

resource "random_password" "hydra_db_password" {
  count = var.hydra_database_password == "" ? 1 : 0
  # count = 0
  length  = 32
  special = false
}

resource "nomad_job" "hydra-kratos" {
  jobspec = templatefile(
    "${path.module}/templates/jobspec.nomad.hcl.tftpl",
    {
      job_name           = var.job_name
      datacenter_name    = var.datacenter_name
      hydra_db_password  = var.hydra_database_password == "" ? random_password.hydra_db_password[0].result : var.hydra_database_password
      kratos_db_password = var.kratos_database_password == "" ? random_password.kratos_db_password[0].result : var.kratos_database_password
      hydra_version      = var.hydra_version
      kratos_version     = var.kratos_version
      postgres_version   = var.postgres_version
      hydra_config       = local.hydra_config
      hydra_public_fqdn  = local.hydra_fqdn
      kratos_config      = local.kratos_config
      kratos_public_fqdn = local.kratos_public_fqdn
    }
  )
}