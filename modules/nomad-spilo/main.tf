locals {
  nodes = [for node in var.nodes : {
    name       = node
    short_name = element(split("-", node), length(split("-", node)) - 1)
  }]
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
    var.postgres_init_script
  ]))
}

resource "nomad_job" "spilo" {
  jobspec = templatefile("${path.module}/templates/spilo.nomad.hcl", {
    job_name                    = var.job_name
    datacenter_name             = var.datacenter_name
    spilo_version               = var.spilo_version
    nodes                       = local.nodes
    etcd_cluster_http           = join(",", [for node in local.nodes : "etcd-${node.short_name}={{ range nomadService \"spilo-${node.short_name}-etcd-peer\" }}http://{{ .Address }}:{{ .Port }}{{ end }}"])
    etcd_cluster                = join(",", [for node in local.nodes : "{{ range nomadService \"spilo-${node.short_name}-etcd-client\" }}{{ .Address }}:{{ .Port }}{{ end }}"])
    backup_schedule             = var.backup_schedule
    s3_access_key               = var.s3_config.access_key
    s3_secret_key               = var.s3_config.secret_key
    s3_endpoint                 = var.s3_config.endpoint
    wal_bucket                  = var.s3_config.wal_bucket
    postgres_superuser_username = var.postgres_superuser_username
    postgres_superuser_password = var.postgres_superuser_password
  })
  purge_on_destroy = var.purge_on_destroy
}

resource "nomad_job" "postgres_init" {
  jobspec = templatefile(
    "${path.module}/templates/postgres-init.nomad.hcl.tftpl",
    {
      job_name                    = var.postgres_init_job_name
      datacenter_name             = var.datacenter_name
      namespace                   = var.namespace
      spilo_version               = var.spilo_version
      postgres_superuser_username = var.postgres_superuser_username
      postgres_superuser_password = var.postgres_superuser_password
      init_script                 = local.postgres_init_script
    }
  )
}
