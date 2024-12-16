# Terraform module for configuring Vault on Flatcar Linux

## Usage

```hcl
module "vault" {
  source          = "github.com/narwhl/blueprint//modules/vault"
  cf_dns_token    = "value"
  cf_zone_token   = "value"
  access_key      = "value"
  secret_key      = "value"
  s3_endpoint     = "https://value.r2.cloudflarestorage.com"
  bucket          = "vault"
  acme_email      = "letsencrypt@domain.tld"
  acme_domain     = "vault.internal.domain.tld"
  webhook_url     = ""
}
```

`cf_dns_token`: Edit token for writing txt record to solve DNS challenge

`cf_zone_token`: Read token for verifying status of issued DNS challenge

`access_key`: S3-compatible bucket access key id

`secret_key`: S3-compatible bucket secret access key

`s3_endpoint`: S3-compatible bucket api url

`bucket`: bucket name

`acme_email`: email for registering with letsencrypt with lego

`acme_domain`: the FQDN that needs obtaining TLS certificate for

`webhook_url`: webhook endpoint for sending unseal/init request to
