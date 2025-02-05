# Terraform module for provisioning PKI

### Usage

```hcl
module "pki" {
  source              = "registry.narwhl.workers.dev/security/pki/tls"
  root_ca_common_name = "ACME"         # required
  root_ca_org_name    = "ACME Inc"     # required
  root_ca_org_unit    = "Product Team" # required
  ttl                 = 8760           # optional, unit is hours and it defaults to 87660 (10 years)
}
```

## Argument Reference

### Required

- `root_ca_common_name` (String) 

- `root_ca_org_name` (String)

- `root_ca_org_unit` (String)

### Optional

- `bit_length` (Number)

- `ttl` (Number)

- `intermediate_ca_ttl` (Number)

- `country` (String)

- `locality` (String)
