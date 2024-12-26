output "tailscale_authkey" {
  value     = tailscale_tailnet_key.this.key
  sensitive = true
}

output "r2_bucket_access_key_id" {
  value     = cloudflare_api_token.this.id
  sensitive = true
}

output "r2_bucket_access_key_id" {
  value     = sha256(cloudflare_api_token.this.value)
  sensitive = true
}