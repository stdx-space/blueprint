locals {
  pgbackrest_conf = var.pgbackrest_s3_config == null ? "" : templatefile(
    "${path.module}/templates/pgbackrest.conf.tftpl",
    {
      s3_endpoint       = var.pgbackrest_s3_config.endpoint
      s3_bucket         = var.pgbackrest_s3_config.bucket
      s3_access_key     = var.pgbackrest_s3_config.access_key
      s3_secret_key     = var.pgbackrest_s3_config.secret_key
      s3_region         = var.pgbackrest_s3_config.region
      pgbackrest_stanza = var.pgbackrest_stanza
    }
  )
  postgres_init = {
    for db in var.postgres_init : db.database => {
      user     = db.user == "" ? db.database : db.user
      password = db.password
      database = db.database
    }
  }
  postgres_init_result = {
    for database, db in local.postgres_init : database => {
      user     = db.user
      password = db.password == "" ? random_password.postgres_password[db.user].result : db.password
      database = db.database
    }
  }
  postgres_init_script = join("\n", concat([
    for database, db in local.postgres_init_result : join("\n", [
      "CREATE USER ${db.user} WITH PASSWORD '${db.password}';",
      "CREATE DATABASE ${db.database} WITH OWNER ${db.user};",
      "GRANT ALL PRIVILEGES ON DATABASE ${db.database} TO ${db.user};",
    ])
    ], [
    "ALTER USER postgres WITH PASSWORD '${random_password.postgres_superuser_password.result}';",
    var.postgres_init_script
  ]))
}

resource "random_password" "postgres_password" {
  for_each = toset(nonsensitive([for db in local.postgres_init : db.user if db.password == ""]))
  length   = 20
  special  = false
}

resource "random_password" "postgres_superuser_password" {
  length  = 20
  special = false
}

resource "nomad_job" "postgres" {
  jobspec = templatefile(
    "${path.module}/templates/postgres.nomad.hcl.tftpl",
    {
      job_name        = var.postgres_job_name
      datacenter_name = var.datacenter_name
      consul_connect_config = var.consul_job_name == "" ? [] : [
        {
          consul_job_name = var.consul_job_name
        }
      ]
      pgbackrest_config = local.pgbackrest_conf == "" ? [] : [
        {
          pgbackrest_conf                  = local.pgbackrest_conf
          pgbackrest_stanza                = var.pgbackrest_stanza
        }
      ]
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      postgres_data_host_volume_name   = var.postgres_host_volumes_name.data
      postgres_log_host_volume_name    = var.postgres_host_volumes_name.log
    }
  )
}

resource "nomad_job" "postgres_init" {
  count = var.restore_backup ? 0 : 1
  jobspec = templatefile(
    "${path.module}/templates/postgres-init.nomad.hcl.tftpl",
    {
      job_name                         = var.postgres_init_job_name
      datacenter_name                  = var.datacenter_name
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      init_script                      = local.postgres_init_script
    }
  )
}

resource "nomad_job" "pgbackrest" {
  count = var.pgbackrest_s3_config == null ? 0 : 1
  jobspec = templatefile(
    "${path.module}/templates/pgbackrest.nomad.hcl.tftpl",
    {
      job_name                         = var.pgbackrest_job_name
      datacenter_name                  = var.datacenter_name
      pgbackrest_conf                  = local.pgbackrest_conf
      pgbackrest_stanza                = var.pgbackrest_stanza
      backup_schedule                  = var.backup_schedule
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      postgres_data_host_volume_name   = var.postgres_host_volumes_name.data
      postgres_log_host_volume_name    = var.postgres_host_volumes_name.log
    }
  )
}

resource "nomad_job" "pgbackrest_init" {
  count = var.restore_backup || var.pgbackrest_s3_config == null ? 0 : 1
  jobspec = templatefile(
    "${path.module}/templates/pgbackrest-init.nomad.hcl.tftpl",
    {
      job_name                         = var.pgbackrest_init_job_name
      datacenter_name                  = var.datacenter_name
      pgbackrest_conf                  = local.pgbackrest_conf
      pgbackrest_stanza                = var.pgbackrest_stanza
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      postgres_data_host_volume_name   = var.postgres_host_volumes_name.data
      postgres_log_host_volume_name    = var.postgres_host_volumes_name.log
    }
  )
}

resource "nomad_job" "pgbackrest_restore" {
  count = var.restore_backup ? 1 : 0
  jobspec = templatefile(
    "${path.module}/templates/pgbackrest-restore.nomad.hcl.tftpl",
    {
      job_name                         = var.pgbackrest_restore_job_name
      datacenter_name                  = var.datacenter_name
      pgbackrest_conf                  = local.pgbackrest_conf
      pgbackrest_stanza                = var.pgbackrest_stanza
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      postgres_data_host_volume_name   = var.postgres_host_volumes_name.data
      postgres_log_host_volume_name    = var.postgres_host_volumes_name.log
    }
  )
}
