# Terraform module for running Mastodon on Nomad

## Usage

```hcl
module "mastodon" {
  source            = "registry.narwhl.workers.dev/stack/mastodon/nomad"
  datacenter_name   = "dc1"
  mastodon_version  = "v4.2.10"
  mastodon_hostname = "mastodon.example.social"
  s3_hostname       = "files.example.social"
  oidc_config = {
    display_name  = "HKUST CAS"
    client_secret = data.external.env.result["OIDC_CLIENT_SECRET"]
    client_id     = data.external.env.result["OIDC_CLIENT_ID"]
    issuer        = data.external.env.result["OIDC_ISSUER"]
  }
  vapid_key = {
    private_key = data.external.env.result["VAPID_PRIVATE_KEY"]
    public_key  = data.external.env.result["VAPID_PUBLIC_KEY"]
  }
  s3_access_key = module.nomad_minio.minio_superuser_details.user
  s3_secret_key = module.nomad_minio.minio_superuser_details.password
  db_user       = "mastodon"
  db_pass       = module.nomad_postgres.postgres_passwords["mastodon"]
  db_name       = "mastodon_production"
}
```

## Argument Reference

`datacenter_name`: `(string: "dc1")` - The name of the Nomad datacenter to use.

`mastodon_version`: `(string: <optional>)` - The version of Mastodon to use.

`mastodon_hostname`: `(string: )` - The hostname of the Mastodon server

`s3_hostname`: `(string: <optional>)` - The hostname of the MinIO server

`oidc_config`: `(object)` - The OIDC configuration.

`vapid_key`: `(object)` - The VAPID key. Generated with `rake mastodon:webpush:generate_vapid_key` from mastodon image.

`s3_access_key`: `(string: <optional>)` - The access key of the MinIO server

`s3_secret_key`: `(string: <optional>)` - The secret key of the MinIO server

`db_user`: `(string: <required>)` - The username of the PostgreSQL database

`db_pass`: `(string: <required>)` - The password of the PostgreSQL database

`db_name`: `(string: <optional>)` - The name of the PostgreSQL database
