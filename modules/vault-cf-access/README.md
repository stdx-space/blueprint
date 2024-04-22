# Terraform module for configuring Vault with Cloudflare Access on Flatcar Linux

```hcl
module "vault" {
  access_key                         = "value"
  secret_key                         = "value"
  bucket                             = "value"
  zone                               = "value"
  cloudflare_account_id              = "value"
  cloudflare_access_service_token_id = "value"
  github_organization                = "value"
  request_origin_ip_domain           = "value"
  webhook_url                        = "value"
}
```

`access_key`: S3-compatible bucket access key id

`secret_key`: S3-compatible bucket secret access key

`s3_endpoint`: S3-compatible bucket api url

`bucket`: bucket name

`zone`: domain name

`cloudflare_account_id`: cloudflare account id

`cloudflare_access_service_token_id`: cloudflare access service token id

`webhook_url`: webhook endpoint for sending unseal/init request to
