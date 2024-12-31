output "cloudflare_tunnel_domain" {
  value       = nonsensitive(var.cloudflare_account_id == "") ? "" : cloudflare_tunnel.ingress[0].cname
  description = "The domain name of the Cloudflare tunnel pointed to traefik"
}

output "cloudflare_tunnel_id" {
  value       = nonsensitive(var.cloudflare_account_id == "") ? "" : cloudflare_tunnel.ingress[0].id
  description = "Tunnel ID for the created resource"
}
