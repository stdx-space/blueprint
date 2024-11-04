# Terraform module for running Traefik as an ingress controller and using cloudflared for traffic gateway on Nomad

Minimal configuration for running the module:

```hcl
module "ingress" {
  datacenter_name                 = "dc1"
  traefik_version                 = ""
  cloudflared_version             = ""
  cloudflare_tunnel_config_source = "local" // recommeded to use local as ingress address can be obtained dynamically through nomad-consul integration
  dns_zone_name                   = "domain.tld"
  cloudflare_account_id           = "" // leave empty to disable cloudflare tunnel component
  acme_email                      = ""
  static_routes                   = "" // static routes defined in traefik dynamic configuration YAML format
}
```

## Nomad Integration

To use nomad service discovery for service discovery, you need to provide the
following configuration:

```hcl
module "ingress" {
  ...
  nomad_provider_config = {
    address = "" // leave empty to use the address from the `nomad` consul service (if nomad has consul integration enabled)
  }
}
```

Address is defaulted empty, so by default the address from the `nomad` consul
service will be used. However, you will at least supply an empty object if you
use all defaulted values.

## Consul Integration

To use consul catelog for service discovery, you need to provide the following configuration:

```hcl
module "ingress" {
  ...
  consul_provider_config = {
    address       = "" // leave empty to use the address from the `consul` consul service (if nomad has consul integration enabled)
    connect_aware = true // whether traefik should discover and connect to consul connect services
    service_name  = "" // Name of the traefik service in consul. This defaults to the controller job name if not provided
  }
}
```

Address is defaulted empty, so by default the address from the `consul` consul
service will be used. However, you will at least supply an empty object if you
use all defaulted values.
