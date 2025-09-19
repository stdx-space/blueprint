# Terraform module for running Hysteria2 on Nomad

This module deploys a Hysteria2 server on Nomad with built-in self-signed TLS
certificates and optional obfuscation (salamander). It supports simple password
authentication and HTTP(S) masquerading.

## Usage

Minimal configuration:

```hcl
module "hysteria" {
  source          = "registry.narwhl.workers.dev/stack/hysteria/nomad"
  datacenter_name = "dc1"

  # Required secrets
  auth_password = var.HYSTERIA_AUTH_PASSWORD
  obfs_password = var.HYSTERIA_OBFS_PASSWORD
}
```

Example with custom ports and masquerade URL:

```hcl
module "hysteria" {
  source          = "registry.narwhl.workers.dev/stack/hysteria/nomad"
  datacenter_name = "dc1"

  job_name       = "hysteria"
  listen_port    = 8443      # container listen port
  bind_port      = 8443      # host port exposed by Nomad
  masquerade_url = "https://www.bing.com/"

  auth_password = data.external.env.result["HYSTERIA_AUTH_PASSWORD"]
  obfs_password = data.external.env.result["HYSTERIA_OBFS_PASSWORD"]
}
```

## Argument Reference

- `job_name`: `(string: "obfs-proxy")` - Name of the Nomad job.

- `datacenter_name`: `(string: "dc1")` - Datacenter to deploy the job to.

- `namespace`: `(string: "default")` - Namespace to deploy the job to.

- `purge_on_destroy`: `(bool: true)` - Whether to purge the job on destroy.

- `masquerade_url`: `(string: "https://www.bing.com/")` - Upstream URL used for HTTP(S) masquerade.

- `obfs_type`: `(string: "salamander")` - Obfuscation type. Currently salamander is used.

- `obfs_password`: `(string: <required>)` - Password for the obfuscation layer.

- `auth_password`: `(string: <required>)` - Client auth password.

- `listen_port`: `(number: 8443)` - Port Hysteria listens on inside the task.

- `bind_port`: `(number: 8443)` - Fixed host port exposed by Nomad for the service.

- `cert_common_name`: `(string: "hysteria.local")` - Common Name of the generated self-signed certificate.

- `cert_organization`: `(string: "Hysteria")` - Organization of the generated self-signed certificate.

- `cert_ttl`: `(number: 87600)` - Self-signed certificate validity in hours (~10 years).

## Outputs

This module has no outputs.

## Notes

- The container image defaulted in the jobspec is `tobyxdd/hysteria:v2.6.0`.
- TLS key/cert are generated at apply time using the `tls` provider and
  mounted into the task at paths defined by the rendered config.
- Obfuscation uses the `salamander` method with the provided `obfs_password`.
- The job exposes a single TLS port; ensure your firewall/security groups allow
  access to `bind_port`.
