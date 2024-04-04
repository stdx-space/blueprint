# Terraform module for provisioning PKI

### Usage

```hcl
module "pki" {
  source              = "github.com/narwhl/blueprint//modules/pki"
  root_ca_common_name = "ACME"         # required
  root_ca_org_name    = "ACME Inc"     # required
  root_ca_org_unit    = "Product Team" # required
  ttl                 = 8760           # optional, unit is hours and it defaults to 87660 (10 years)
}
```
