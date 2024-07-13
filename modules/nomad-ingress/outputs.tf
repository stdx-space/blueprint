output "cloudflare_tunnel_domain" {
  value       = cloudflare_tunnel.ingress.cname
  description = "The domain name of the Cloudflare tunnel pointed to traefik"
}

output "cloudflare_tunnel_id" {
  value       = cloudflare_tunnel.ingress.id
  description = "Tunnel ID for the created resource"
}
