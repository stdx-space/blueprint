# Terraform module for running Traefik as an ingress controller and using cloudflared for traffic gateway on Nomad

Minimal configuration for running the module:

```hcl
module "ingress" {
  source                          = "registry.narwhl.workers.dev/stack/ingress/nomad"
  datacenter_name                 = "dc1"
  traefik_version                 = ""
  cloudflared_version             = ""
  cloudflare_tunnel_config_source = "local" // recommeded to use local as ingress address can be obtained dynamically through nomad-consul integration
  dns_zone_name                   = "domain.tld"
  cloudflare_account_id           = "" // leave empty to disable cloudflare tunnel component
  acme_email                      = ""
  static_routes                   = "" // static routes defined in traefik dynamic configuration YAML format
  use_https                       = true // whether to use https for communication between cloudflare tunnel and traefik
}
```

## Cloudflare Tunnel Configuration Source

Cloudflare tunnel have two modes of configuration source, which can be
specified via `cloudflare_tunnel_config_source` variable:

- local: cloudflare uses the tunnel configuration from local configuration file
in the container. The module uses the template functionality in Nomad to render
a dynamic configuration file pointing to `traefik` address depending on
`traefik` consul service address at runtime.
- cloudflare: cloudflare uses the tunnel configuration from the cloudflare. The
module will fetch `traefik` address from the `traefik` consul service while
applying the Terraform configuration and upload the tunnel configuration to
cloudflare during Terraform apply.

You are recommendend to use `local` as configuration source as the ingress
config can be updated dynamically without the need of re-applying the Terraform
configuration.

## Cloudflare Tunnel Configuration Source

Cloudflare tunnel have two modes of configuration source, which can be
specified via `cloudflare_tunnel_config_source` variable:

- local: cloudflare uses the tunnel configuration from local configuration file
in the container. The module uses the template functionality in Nomad to render
a dynamic configuration file pointing to `traefik` address depending on
`traefik` consul service address at runtime.
- cloudflare: cloudflare uses the tunnel configuration from the cloudflare. The
module will fetch `traefik` address from the `traefik` consul service while
applying the Terraform configuration and upload the tunnel configuration to
cloudflare during Terraform apply.

You are recommendend to use `local` as configuration source as the ingress
config can be updated dynamically without the need of re-applying the Terraform
configuration.

## Default Traefik Configuration

By default, this module sets up 2 entrypoints for traefik ingress:

- http: 80
- https: 443

Cloudflare tunnel by default connects to the `http` entrypoint. To make
services accessible through cloudflare, configure ingress to point to
the service through the `http` entrypoint.

### Adding Static Routes

The following example shows traefik configuration for adding a static route.
Put the following in the `static_routes` variable for adding the route via
the module:

```yaml
http:
  routers:
    my-service:
      rule: Host(`my-service.domain.tld`)
      entrypoints:
        - http
      service: my-service
  services:
    my-service:
      loadBalancer:
        servers:
          - url: http://127.0.0.1:8080
```

The example sets up a static route for `my-service` with the hostname
`my-service.domain.tld` to point to the `http` entrypoint. The service would
be accessible through `http://my-service.domain.tld` after configuring the DNS
record for `my-service.domain.tld` to point to the ingress address.

```hcl
resource "cloudflare_record" "tunnel_domains" {
  zone_id  = "..."
  name     = "my-service.domain.tld"
  value    = module.nomad_ingress.cloudflare_tunnel_domain // output of this module
  type     = "CNAME"
  proxied  = true
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

### Attaching Tags to Nomad Services

The below example shows how to attach tags to a nomad service for traefik
ingress. The example sets up a route for `my-service` with the hostname
`my-service.domain.tld` to attach to the `http` entrypoint. The service would
be accessible through `http://my-service.domain.tld` after configuring the
DNS record for `my-service.domain.tld` to point to the ingress address.

```hcl
service {
  name = "my-service"
  provider = "nomad"
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.my-service.rule=Host(`my-service.domain.tld`)",
    "traefik.http.routers.my-service.entrypoints=http",
  ]
}
```

Configure the DNS record with the same way as the static route example.

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

### Attaching Tags to Consul Services

The method for attaching tags to consul services is similar to Nomad. However,
you need to be aware when using Consul Connect.

#### Without Consul Connect

If you decided not to connect traefik to the service via Consul Connect, you
can refer to the below example. You will still be able to use Consul connect
to access other service. Note that sidecar service inherits the tags
from the service it is attached to. You will need to explicitly disable
traefik for the sidecar service.

```hcl
service {
  name = "my-service"
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.my-service.rule=Host(`my-service.domain.tld`)",
    "traefik.http.routers.my-service.entrypoints=http",
  ]
  connect {
    sidecar_service {
      proxy {}
      tags = [
        "traefik.enable=false", # disable traefik for sidecar service
      ]
    }
  }
}
```

Configure the DNS record with the same way as the static route example.

#### With Consul Connect

To use Consul connect with the service, you will need to explicitly enable
it by setting `traefik.consulcatalog.connect=true` in the service tags. In
this case, keep the default tag for sidecar service to inherit the tags from
parent service.

```hcl
service {
  name = "my-service"
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.my-service.rule=Host(`my-service.domain.tld`)",
    "traefik.http.routers.my-service.entrypoints=http",
    "traefik.consulcatalog.connect=true", # enable consul connect for the service
  ]
  connect {
    sidecar_service {
      proxy {}
    }
  }
}
```

Configure the DNS record with the same way as the static route example.
