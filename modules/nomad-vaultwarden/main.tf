locals {
  nomad_var_template        = "{{ with nomadVar \"nomad/jobs/${var.job_name}\" }}{{ .%s }}{{ end }}"
  backup_entrypoint_script  = file("${path.module}/templates/backup.entrypoint.sh")
  restore_entrypoint_script = file("${path.module}/templates/restore.entrypoint.sh")
  restic_env = {
    RESTIC_REPOSITORY     = "s3:${var.s3_use_ssl ? "https" : "http"}://${var.s3_endpoint}/${var.s3_backup_bucket}"
    RESTIC_PASSWORD       = format(local.nomad_var_template, "restic_password")
    AWS_ACCESS_KEY_ID     = format(local.nomad_var_template, "s3_access_key")
    AWS_SECRET_ACCESS_KEY = format(local.nomad_var_template, "s3_secret_key")
  }
  crontab = <<-EOF
  ${var.backup_schedule} restic backup /alloc/data/vaultwarden > /proc/1/fd/1 2> /proc/1/fd/2
  EOF
  litestream_config = {
    access-key-id     = format(local.nomad_var_template, "s3_access_key")
    secret-access-key = format(local.nomad_var_template, "s3_secret_key")
    dbs = [
      {
        path = "/alloc/data/db.sqlite3"
        replicas = [
          {
            type             = "s3"
            bucket           = var.s3_replication_bucket
            endpoint         = "${var.s3_use_ssl ? "" : "http://"}${var.s3_endpoint}"
            force_path_style = true
          }
        ]
      }
    ]
  }
}

resource "nomad_variable" "vaultwarden" {
  path = "nomad/jobs/${var.job_name}"
  items = {
    restic_password = var.restic_password
    s3_access_key   = var.s3_access_key
    s3_secret_key   = var.s3_secret_key
  }
}

resource "nomad_job" "vaultwarden" {
  purge_on_destroy = var.purge_on_destroy
  jobspec = templatefile(
    "${path.module}/templates/vaultwarden.nomad.hcl.tftpl",
    {
      job_name                   = var.job_name
      datacenter                 = var.datacenter_name
      namespace                  = var.namespace
      resources                  = var.resources
      vaultwarden_version        = var.vaultwarden_version
      litestream_version         = var.litestream_version
      restic_version             = var.restic_version
      fqdn                       = var.fqdn
      service_discovery_provider = var.service_discovery_provider
      traefik_entrypoints        = var.traefik_entrypoint
      litestream_config          = yamlencode(local.litestream_config)
      backup_entrypoint_script   = local.backup_entrypoint_script
      restore_entrypoint_script  = local.restore_entrypoint_script
      restic_env                 = join("\n", [for k, v in local.restic_env : "${k}=${v}"])
      crontab                    = local.crontab
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

