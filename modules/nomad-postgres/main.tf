locals {
  pgbackrest_conf = var.pgbackrest_s3_config == null ? "" : templatefile(
    "${path.module}/templates/pgbackrest.conf.tftpl",
    {
      postgres_version      = var.postgres_version
      postgres_cluster_name = var.postgres_cluster_name
      postgres_port         = var.postgres_port
      s3_endpoint           = var.pgbackrest_s3_config.endpoint
      s3_bucket             = var.pgbackrest_s3_config.bucket
      s3_access_key         = var.pgbackrest_s3_config.access_key
      s3_secret_key         = var.pgbackrest_s3_config.secret_key
      s3_region             = var.pgbackrest_s3_config.region
      s3_force_path_style   = var.pgbackrest_s3_config.force_path_style
      full_retention_count  = var.backup_schedule.full.retention_count
      pgbackrest_stanza     = var.pgbackrest_stanza
    }
  )
  postgres_superuser_password = var.postgres_superuser_password == "" ? random_password.postgres_superuser_password[0].result : var.postgres_superuser_password
  postgres_init = {
    for db in var.postgres_init : db.database => {
      user        = db.user == "" ? db.database : db.user
      password    = db.password
      database    = db.database
      create_user = db.create_user
    }
  }
  postgres_init_result = {
    for database, db in local.postgres_init : database => {
      user        = db.user
      password    = db.password == "" && db.create_user ? random_password.postgres_password[db.user].result : db.password
      database    = db.database
      create_user = db.create_user
    }
  }
  postgres_init_script = join("\n", concat([
    for database, db in local.postgres_init_result : "CREATE USER ${db.user} WITH PASSWORD '${db.password}';"
    if db.create_user
    ], [
    for database, db in local.postgres_init_result : join("\n", [
      "CREATE DATABASE ${db.database} WITH OWNER ${db.user};",
      "GRANT ALL PRIVILEGES ON DATABASE ${db.database} TO ${db.user};",
    ])
    ], [
    "ALTER USER postgres WITH PASSWORD '${local.postgres_superuser_password}';",
    var.postgres_init_script
  ]))
}

resource "random_password" "postgres_password" {
  for_each = toset(nonsensitive([for db in local.postgres_init : db.user if db.password == "" && db.create_user]))
  length   = 20
  special  = false
}

resource "random_password" "postgres_superuser_password" {
  count   = var.postgres_superuser_password == "" ? 1 : 0
  length  = 20
  special = false
}

resource "nomad_job" "postgres" {
  count = var.restore_backup != null ? 0 : 1
  jobspec = templatefile(
    "${path.module}/templates/postgres.nomad.hcl.tftpl",
    {
      job_name              = var.postgres_job_name
      datacenter_name       = var.datacenter_name
      postgres_version      = var.postgres_version
      postgres_cluster_name = var.postgres_cluster_name
      postgres_port         = var.postgres_port
      consul_config = var.consul_job_name != "" && !var.consul_connect ? [
        {
          consul_job_name = var.consul_job_name
        }
      ] : []
      consul_connect_config = var.consul_job_name != "" && var.consul_connect ? [
        {
          consul_job_name = var.consul_job_name
        }
      ] : []
      pgbackrest_config = local.pgbackrest_conf == "" ? [] : [
        {
          pgbackrest_conf   = local.pgbackrest_conf
          pgbackrest_stanza = var.pgbackrest_stanza
        }
      ]
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      postgres_data_host_volume_name   = var.postgres_host_volumes_name.data
      postgres_log_host_volume_name    = var.postgres_host_volumes_name.log
    }
  )
  purge_on_destroy = var.purge_on_destroy
}

resource "nomad_job" "postgres_init" {
  count = var.restore_backup != null ? 0 : 1
  jobspec = templatefile(
    "${path.module}/templates/postgres-init.nomad.hcl.tftpl",
    {
      job_name                         = var.postgres_init_job_name
      datacenter_name                  = var.datacenter_name
      postgres_port                    = var.postgres_port
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      init_script                      = local.postgres_init_script
    }
  )
  purge_on_destroy = var.purge_on_destroy
}

resource "nomad_job" "pgbackrest_full" {
  count = var.pgbackrest_s3_config == null ? 0 : 1
  jobspec = templatefile(
    "${path.module}/templates/pgbackrest.nomad.hcl.tftpl",
    {
      job_name                         = var.pgbackrest_job_name
      datacenter_name                  = var.datacenter_name
      pgbackrest_conf                  = local.pgbackrest_conf
      pgbackrest_stanza                = var.pgbackrest_stanza
      backup_schedule                  = var.backup_schedule.full.schedule
      backup_type                      = "full"
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      postgres_data_host_volume_name   = var.postgres_host_volumes_name.data
      postgres_log_host_volume_name    = var.postgres_host_volumes_name.log
    }
  )
  purge_on_destroy = var.purge_on_destroy
}

resource "nomad_job" "pgbackrest_incremental" {
  count = var.pgbackrest_s3_config == null ? 0 : 1
  jobspec = templatefile(
    "${path.module}/templates/pgbackrest.nomad.hcl.tftpl",
    {
      job_name                         = var.pgbackrest_job_name
      datacenter_name                  = var.datacenter_name
      pgbackrest_conf                  = local.pgbackrest_conf
      pgbackrest_stanza                = var.pgbackrest_stanza
      backup_schedule                  = var.backup_schedule.incremental.schedule
      backup_type                      = "incr"
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      postgres_data_host_volume_name   = var.postgres_host_volumes_name.data
      postgres_log_host_volume_name    = var.postgres_host_volumes_name.log
    }
  )
  purge_on_destroy = var.purge_on_destroy
}

resource "nomad_job" "pgbackrest_init" {
  count = var.restore_backup != null || var.pgbackrest_s3_config == null ? 0 : 1
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
  purge_on_destroy = var.purge_on_destroy
}

resource "nomad_job" "pgbackrest_restore" {
  count = var.restore_backup != null ? 1 : 0
  jobspec = templatefile(
    "${path.module}/templates/pgbackrest-restore.nomad.hcl.tftpl",
    {
      job_name                         = var.pgbackrest_restore_job_name
      datacenter_name                  = var.datacenter_name
      postgres_version                 = var.postgres_version
      postgres_cluster_name            = var.postgres_cluster_name
      pgbackrest_conf                  = local.pgbackrest_conf
      pgbackrest_stanza                = var.pgbackrest_stanza
      postgres_socket_host_volume_name = var.postgres_host_volumes_name.socket
      postgres_data_host_volume_name   = var.postgres_host_volumes_name.data
      postgres_log_host_volume_name    = var.postgres_host_volumes_name.log
    }
  )
  purge_on_destroy = var.purge_on_destroy
}
