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

Traefik ingress may be configured to use Nomad service catalog as a source of
service discovery. In this case, traefik will obtain service catalog from the
nomad endpoint in the configuration, and add tagged service in Nomad to traefik
configuration dynamically.

https://doc.traefik.io/traefik/providers/nomad/

```hcl
module "ingress" {
  ...// other configurations
  nomad_provider_config = {
    address = "" // leave empty to use the address from the `nomad` consul service (if nomad has consul integration enabled)
  }
}
```

Address is defaulted empty, so by default the address from the `nomad` consul
service will be used. That is, it will obtain the nomad address from the consul
service catalog. However, you will at least supply an empty object if you
use all defaulted values.

## Consul Integration

Traefik ingress may be configured to use Consul service catalog as a source of
service discovery. This is similar to the nomad integration, but instead of
using the Nomad service catalog, it will use the Consul service catalog as the
configuration source. In this case, traefik will obtain service catalog from
the consul endpoint in the configuration, and add tagged service in Consul to
traefik configuration dynamically.

Different from Nomad integration, Consul integration has the additonal option
for configuring whether traefik should discover consul connect enabled
services. Enabling this option will set traefik job to be Consul connect
native. Then, traefik ingress will connect to services tagged with connect
enabled with Consul connect.

https://doc.traefik.io/traefik/providers/consul-catalog/

```hcl
module "ingress" {
  ...// other configurations
  consul_provider_config = {
    address       = "" // leave empty to use the address from the `consul` consul service (if nomad has consul integration enabled)
    connect_aware = true // whether traefik should discover and connect to consul connect services, defaults to true
    service_name  = "" // Name of the traefik service in consul. This defaults to the controller job name if not provided. This is only required if you need to customize the controller service name appeared in Consul catalog.
  }
}
```

Address is defaulted empty, so by default the address from the `consul` consul
service will be used. That is, it will obtain the consul address from the
consul service catalog. However, you will at least supply an empty object if
you use all defaulted values.
