# Terraform module for running Traefik as an ingress controller and using cloudflared for traffic gateway on Nomad

```hcl
module "ingress" {
  datacenter_name       = "dc1"
  traefik_version       = ""
  cloudflared_version   = ""
  dns_zone_name         = "domain.tld"
  cloudflare_account_id = ""
  acme_email            = ""
  static_routes         = ""
}
```