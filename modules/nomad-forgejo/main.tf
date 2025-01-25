locals {
  # default docker configuration for forgejo can be found here:
  # https://codeberg.org/forgejo/forgejo/src/branch/forgejo/docker/root/etc/templates/app.ini
  forgejo_env = {
    APP_NAME                                   = var.app_name
    DOMAIN                                     = var.domain
    SSH_DOMAIN                                 = var.ssh_domain
    HTTP_PORT                                  = 3000
    ROOT_URL                                   = "${var.protocol}://${var.domain}"
    DISABLE_SSH                                = false
    SSH_PORT                                   = var.external_ssh_port
    DB_TYPE                                    = var.db_type
    FORGEJO__database__PATH                    = "/alloc/forgejo.db"
    DISABLE_REGISTRATION                       = var.disable_registration
    REQUIRE_SIGNIN_VIEW                        = var.require_signin_view
    FORGEJO__storage__STORAGE_TYPE             = "minio"
    FORGEJO__storage__MINIO_ENDPOINT           = var.minio_endpoint
    FORGEJO__storage__MINIO_ACCESS_KEY_ID      = var.minio_access_key
    FORGEJO__storage__MINIO_SECRET_ACCESS_KEY  = var.minio_secret_key
    FORGEJO__storage__MINIO_BUCKET             = var.minio_data_bucket
    FORGEJO__storage__MINIO_USE_SSL            = var.minio_use_ssl
    FORGEJO__storage__MINIO_CHECKSUM_ALGORITHM = var.minio_checksum_algorithm
    FORGEJO__repository__ROOT                  = "/alloc/git/repositories"
    FORGEJO__security__INSTALL_LOCK            = true # for skipping intall wizard, https://forum.gitea.com/t/unattended-gitea-installation-from-the-cli/3373/22
  }
  litestream_config = {
    access-key-id     = var.minio_access_key
    secret-access-key = var.minio_secret_key
    dbs = [
      {
        path = "/alloc/forgejo.db"
        replicas = [
          {
            type             = "s3"
            bucket           = var.minio_replication_bucket
            endpoint         = "${var.minio_use_ssl ? "" : "http://"}${var.minio_endpoint}"
            force_path_style = true
          }
        ]
      }
    ]
  }
  restic_env = {
    RESTIC_REPOSITORY     = "s3:${var.minio_use_ssl ? "https" : "http"}://${var.minio_endpoint}/${var.minio_backup_bucket}"
    RESTIC_PASSWORD       = var.restic_password
    AWS_ACCESS_KEY_ID     = var.minio_access_key
    AWS_SECRET_ACCESS_KEY = var.minio_secret_key
  }
  backup_entrypoint_script  = file("${path.module}/templates/backup.entrypoint.sh")
  restore_entrypoint_script = file("${path.module}/templates/restore.entrypoint.sh")
  # modified from https://stackoverflow.com/a/47960145
  crontab = <<-EOF
  ${var.backup_schedule} restic backup /alloc/git > /proc/1/fd/1 2> /proc/1/fd/2
  EOF
  forgejo_jobspec = templatefile("${path.module}/templates/forgejo.nomad.hcl", {
    job_name                   = var.job_name
    datacenter                 = var.datacenter_name
    namespace                  = var.namespace
    service_discovery_provider = var.service_discovery_provider
    resources                  = var.resources
    forgejo_version            = var.forgejo_version
    litestream_version         = var.litestream_version
    restic_version             = var.restic_version
    domain                     = var.domain
    traefik_entrypoints        = var.traefik_entrypoint
    forgejo_env                = join("\n", [for k, v in local.forgejo_env : "${k}=${v}"])
    litestream_config          = yamlencode(local.litestream_config)
    backup_entrypoint_script   = local.backup_entrypoint_script
    restore_entrypoint_script  = local.restore_entrypoint_script
    restic_env                 = join("\n", [for k, v in local.restic_env : "${k}=${v}"])
    crontab                    = local.crontab
  })
}

resource "nomad_job" "forgejo" {
  jobspec          = local.forgejo_jobspec
  purge_on_destroy = var.purge_on_destroy
}
