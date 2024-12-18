# Terraform module for provisioning PKI

### Usage

```hcl
module "pki" {
  source              = "registry.narwhl.workers.dev/generic/pki/tls"
  root_ca_common_name = "ACME"         # required
  root_ca_org_name    = "ACME Inc"     # required
  root_ca_org_unit    = "Product Team" # required
  ttl                 = 8760           # optional, unit is hours and it defaults to 87660 (10 years)
  # optional, list of client certificates to generate
  extra_client_certificates = [
    {
      common_name = "Client 1"
    }
  ]
  # optional, list of server certificates to generate
  extra_server_certificates = [
    {
      san_dns_names = ["server.global.nomad"]
      san_ip_addresses = ["127.0.0.1"]
    }
  ]
}
```
