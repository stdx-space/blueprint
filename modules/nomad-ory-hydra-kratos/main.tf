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

resource "random_password" "db_admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "kratos_db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "hydra_db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "nomad_job" "hydra-kratos" {
  jobspec = templatefile(
    "${path.module}/templates/jobspec.nomad.hcl.tftpl",
    {
      job_name           = var.job_name
      datacenter_name    = var.datacenter_name
      db_password        = random_password.db_admin.result
      hydra_db_password  = random_password.hydra_db_password.result
      kratos_db_password = random_password.kratos_db_password.result
      hydra_version      = var.hydra_version
      kratos_version     = var.kratos_version
      postgres_version   = var.postgres_version
      hydra_config       = local.hydra_config
      kratos_config      = local.kratos_config
    }
  )
}