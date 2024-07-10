output "cloudflare_tunnel_domain" {
  value       = cloudflare_tunnel.ingress.cname
  description = "The domain name of the Cloudflare tunnel pointed to traefik"
}
