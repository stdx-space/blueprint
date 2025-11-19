locals {
  nomad_var_template = "{{ with nomadVar `nomad/jobs/${var.job_name}` }}{{ .%s }}{{ end }}"
}

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

resource "nomad_variable" "hydra_kratos" {
  path = "nomad/jobs/${var.job_name}"
  items = merge(
    {
      hydra_cookie_secret      = random_bytes.hydra_cookie_secret.hex
      hydra_system_secret      = random_bytes.hydra_system_secret.hex
      hydra_oidc_pairwise_salt = random_bytes.hydra_oidc_pairwise_salt.hex
      kratos_secret_cipher     = random_bytes.kratos_secret_cipher.hex
      kratos_cookie_secret     = random_bytes.kratos_cookie_secret.hex
      db_password              = var.database_password
      smtp_connection_uri      = var.smtp_connection_uri
    },
    {
      for provider in var.kratos_oidc_providers :
      "oidc_${provider.id}_client_secret" => provider.client_secret
    }
  )
}

resource "nomad_job" "hydra_kratos" {
  jobspec = templatefile(
    "${path.module}/templates/jobspec.nomad.hcl.tftpl",
    {
      job_name              = var.job_name
      datacenter_name       = var.datacenter_name
      namespace             = var.namespace
      db_user               = var.database_user
      db_password           = format(local.nomad_var_template, "db_password")
      db_addr               = var.database_addr
      db_sslmode            = var.database_sslmode
      hydra_db_name         = var.hydra_db_name
      kratos_db_name        = var.kratos_db_name
      hydra_version         = var.hydra_version
      kratos_version        = var.kratos_version
      hydra_config          = local.hydra_config
      hydra_public_fqdn     = local.hydra_fqdn
      kratos_config         = local.kratos_config
      kratos_public_fqdn    = local.kratos_public_fqdn
      traefik_entrypoint    = var.traefik_entrypoint
      traefik_cert_resolver = var.traefik_cert_resolver
    }
  )
}
