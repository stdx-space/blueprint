data "external" "env" {
  program = ["jq", "-n", "env"]
}

locals {
  mastodon_env = {
    LOCAL_DOMAIN                           = var.mastodon_hostname
    REDIS_HOST                             = var.redis_host
    REDIS_PORT                             = var.redis_port
    DB_HOST                                = var.db_host
    DB_USER                                = var.db_user
    DB_NAME                                = var.db_name
    DB_PASS                                = var.db_pass
    DB_PORT                                = var.db_port
    ES_ENABLED                             = false
    SECRET_KEY_BASE                        = random_id.secret_key_base.hex
    OTP_SECRET                             = random_id.otp_secret.hex
    VAPID_PRIVATE_KEY                      = var.vapid_key.private_key
    VAPID_PUBLIC_KEY                       = var.vapid_key.public_key
    S3_ENABLED                             = true
    S3_ENDPOINT                            = var.s3_endpoint
    S3_BUCKET                              = var.s3_bucket
    AWS_ACCESS_KEY_ID                      = var.s3_access_key
    AWS_SECRET_ACCESS_KEY                  = var.s3_secret_key
    S3_HOSTNAME                            = var.s3_hostname
    IP_RETENTION_PERIOD                    = 31556952
    SESSION_RETENTION_PERIOD               = 31556952
    OIDC_ENABLED                           = true
    OIDC_DISPLAY_NAME                      = var.oidc_config.display_name
    OIDC_ISSUER                            = var.oidc_config.issuer
    OIDC_DISCOVERY                         = true
    OIDC_SCOPE                             = "openid,profile,email"
    OIDC_UID_FIELD                         = "preferred_username"
    OIDC_REDIRECT_URI                      = "https://${var.mastodon_hostname}/auth/auth/openid_connect/callback"
    OIDC_SECURITY_ASSUME_EMAIL_IS_VERIFIED = true
    OIDC_CLIENT_ID                         = var.oidc_config.client_id
    OIDC_CLIENT_SECRET                     = var.oidc_config.client_secret
    OMNIAUTH_ONLY                          = true
    ONE_CLICK_SSO_LOGIN                    = true
  }
  mastodon_env_file = join("\n", [for k, v in local.mastodon_env : "${k}=${v}"])
}

resource "nomad_job" "mastodon_init" {
  jobspec = templatefile("${path.module}/templates/mastodon-init.nomad.hcl.tftpl", {
    job_name          = var.init_job_name
    datacenter_name   = var.datacenter_name
    mastodon_version  = var.mastodon_version
    mastodon_env_file = local.mastodon_env_file
  })
}

resource "nomad_job" "mastodon" {
  jobspec = templatefile("${path.module}/templates/mastodon.nomad.hcl.tftpl", {
    job_name          = var.job_name
    datacenter_name   = var.datacenter_name
    mastodon_hostname = var.mastodon_hostname
    mastodon_version  = var.mastodon_version
    mastodon_env_file = local.mastodon_env_file
  })
}
