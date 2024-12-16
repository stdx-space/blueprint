data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "this" {
  name = "vault"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.r2["Workers R2 Storage Bucket Item Read"],
      data.cloudflare_api_token_permission_groups.all.r2["Workers R2 Storage Bucket Item Write"],
    ]
    resources = {
      format(
        "com.cloudflare.edge.r2.bucket.%s_default_%s",
        data.external.env.result.CLOUDFLARE_ACCOUNT_ID,
        "vault"
      ) = "*"
    }
  }
}

resource "tailscale_tailnet_key" "this" {
  preauthorized = true
  ephemeral     = false
  description   = "Vault"
}

resource "tailscale_webhook" "this" {
  endpoint_url = ""
  subscriptions = ["subnetIPForwardingNotEnabled", "nodeCreated"]
}

resource "nomad_job" "vault" {
  jobspec = templatefile("${path.module}/templates/vault.nomad.hcl", {
    domain            = var.domain
    coredns_version   = local.pkgs.coredns.version
    vault_version     = local.pkgs.vault.version
    access_key        = cloudflare_api_token.this.id
    secret_key        = sha256(cloudflare_api_token.this.value)
    bucket            = var.bucket
    endpoint          = format("https://%s.r2.cloudflarestorage.com", data.external.env.result.CLOUDFLARE_ACCOUNT_ID)
    tailscale_authkey = tailscale_tailnet_key.this.key
    log_level         = var.log_level
  })
  purge_on_destroy = true
}