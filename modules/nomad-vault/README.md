# Terraform module for configuring Vault on Nomad
## Usage

```hcl
module "vault" {
  source          = "registry.narwhl.workers.dev/stack/vault/nomad"
  bucket          = "vault"
  log_level       = "debug"
  domain          = "tld.internal"
  webhook_url     = "https://handler.tld/webhook"
}
```

`bucket`: bucket name

`webhook_url`: webhook endpoint for sending unseal/init request to
