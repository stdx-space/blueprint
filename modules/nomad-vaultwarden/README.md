# Terraform module for running Vaultwarden on Nomad with automatic backup and restore

## Usage

```hcl
module "vaultwarden" {
  source              = "registry.narwhl.workers.dev/stack/vaultwarden/nomad"
  vaultwarden_version   = "latest"
  litestream_version    = "latest"
  restic_version        = "latest"
  fqdn                  = "vaultwarden.internal.tld"
  s3_access_key         = "..."
  s3_secret_key         = "..."
  s3_replication_bucket = "vw" # for litestream streaming replication
  s3_endpoint           = "https://minio.your.tld"
  s3_backup_bucket      = "backup"
  restic_password       = "..."
}
```

## Argument Reference

- `job_name`: `(string: "vaultwarden")` - The name of the Nomad job.

- `datacenter_name`: `(string: "dc1")` - The datacenter to deploy the job to.

- `namespace`: `(string: "default")` - The namespace to deploy the job to.

- `vaultwarden_version`: `(string: <required>)` - The version of Vaultwarden to deploy.

- `litestream_version`: `(string: <required>)` - The version of Litestream to deploy.

- `restic_version`: `(string: <required>)` - The version of Restic to deploy.

- `fqdn`: `(string: <required>)` - The fully qualified domain name for the Vaultwarden service.

- `s3_access_key`: `(string: <required>)` - The access key for the S3 bucket.

- `s3_secret_key`: `(string: <required>)` - The secret key for the S3 bucket.

- `s3_replication_bucket`: `(string: <required>)` - The S3 bucket to use for Litestream replication.

- `s3_endpoint`: `(string: <required>)` - The S3 endpoint to use.

- `s3_backup_bucket`: `(string: <required>)` - The S3 bucket to use for Restic backups.

- `s3_use_ssl`: `(bool: true)` - Whether to use SSL when connecting to the S3 endpoint.

- `backup_schedule`: `(string: "*/5 * * * *")` - The schedule to use for Restic backups.

- `service_discovery_provider`: `(string: "consul")` - The service discovery provider to use.

- `traefik_entrypoints`: `(object: <optional>)` - The Traefik entrypoints to use.

- `restic_password`: `(string: <required>)` - The password to use for Restic backups.

- `resources`: `(object: {})` - The resources to allocate to the job.

- `purge_on_destroy`: `(bool: true)` - Whether to purge the job when it is destroyed.
