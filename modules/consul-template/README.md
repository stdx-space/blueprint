# Terraform module for Consul Template

## Usage

```hcl
module "consul-template" {
  source            = "registry.narwhl.workers.dev/service/consul-template/systemd"
  consul_auth_token = "..."
  consul_address    = "consul.some.tld:8500"
  templates = {
    "nginx" = {
      source = "nginx.conf.ctmpl"
      destination = "/etc/nginx/nginx.conf"
      command = "systemctl reload nginx"
    }
  }
}
```

## Argument Reference

- `supplychain`: `(string: <optional>)` - The supply chain to use.

- `consul_auth_token`: `(string: <required>)` - The ACL token to authenticate to Consul Server for accesing KV store.

- `consul_address`: `(string: <required>)` - The address of the Consul Server.

- `templates`: `(map(object): <required>)` - List of templates to render.
