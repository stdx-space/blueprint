# Terraform module for self hosting Forgejo on Nomad

This module deploys a Forgejo instance on Nomad. It also comes with data
replication for disaster recovery of persistent data.

## Usage

### Example configuration

Below shows an example configuration for a Forgejo instance.

```hcl
module "forgejo" {
  source                   = "./forgejo"
  datacenter_name          = "dc1"
  protocol                 = "http"
  domain                   = "10.100.89.184"
  ssh_domain               = "10.100.89.184"
  minio_endpoint           = "{{ with nomadService `minio` }}{{ with index . 0 }}{{ .Address }}:{{ .Port }}{{ end }}{{ end }}"
  minio_access_key         = "miniosuperadmin"
  minio_secret_key         = "miniosuperadmin"
  minio_data_bucket        = "forgejo-data"
  minio_replication_bucket = "forgejo-litestream"
  minio_backup_bucket      = "forgejo-backup"
  minio_use_ssl            = false
  restic_password          = "resticsuperadmin"
}
```

You may use the minio module for S3 storage.

```hcl
module "nomad_minio" {
  source                   = "registry.narwhl.workers.dev/stack/minio/nomad"
  datacenter_name          = "dc1"
  minio_hostname           = "files.example.app"
  minio_superuser_name     = "miniosuperadmin"
  minio_superuser_password = "miniosuperadmin"
  create_buckets = [
    {
      name = "forgejo-data"
    },
    {
      name = "forgejo-litestream"
    },
    {
      name = "forgejo-backup"
    }
  ]
  service_discovery_provider = "nomad"
}
```

## Design

### Data Persistence

The Forgejo instance is designed to run statelessly, relying on continuous
database replication and repository backups for storing data. All data are
stored in S3 buckets. When spinned up, the module will try to restore the
instance to previous state by pulling the latest backup from the backup bucket.

### Database Replication

The module uses Litestream to replicate the database. All database changes are
replicated to the specified S3 bucket continuously.

### Repository Backups

The module uses Restic to backup git repositories. Restic backup jobs are
scheduled to run every 5 minutes (configurable) with cron.

## Argument Reference

- `datacenter_name`: `(string: <required>)` - The name of the Nomad datacenter to use.

- `namespace`: `(string: <optional>)` - The namespace to run the job in. Defaults to `default`.

- `job_name`: `(string: <optional>)` - The name of the job. Defaults to `forgejo`.

- `service_discovery_provider`: `(string: <optional>)` - The service discovery provider to use. Defaults to `consul`.

- `resources`: `(object: <optional>)` - The resources to allocate to the job.

- `purge_on_destroy`: `(bool: <optional>)` - Whether to purge the job on destroy. Defaults to `false`.

- `forgejo_version`: `(string: <optional>)` - The version of Forgejo to run. Defaults to `latest`.

- `litestream_version`: `(string: <optional>)` - The version of Litestream to run. Defaults to `latest`.

- `restic_version`: `(string: <optional>)` - The version of Restic to run. Defaults to `latest`.

- `traefik_entrypoint`: `(object: <optional>)` - The entrypoints to expose the service.

- `app_name`: `(string: <optional>)` - The name of the Forgejo instance. Defaults to `forgejo`.

- `domain`: `(string: <required>)` - The domain to access the Forgejo instance.

- `protocol`: `(string: <optional>)` - The protocol to access the Forgejo instance. Defaults to `http`.

- `ssh_domain`: `(string: <required>)` - The domain to access the Forgejo instance via SSH.

- `disable_registration`: `(bool: <optional>)` - Whether to disable registration. Defaults to `false`.

- `require_signin_view`: `(bool: <optional>)` - Whether to require sign in to view the Forgejo instance. Defaults to `false`.

- `minio_endpoint`: `(string: <required>)` - The MinIO endpoint to use.

- `minio_access_key`: `(string: <required>)` - The MinIO access key to use.

- `minio_secret_key`: `(string: <required>)` - The MinIO secret key to use.

- `minio_data_bucket`: `(string: <required>)` - The MinIO bucket to store Forgejo data.

- `minio_replication_bucket`: `(string: <required>)` - The MinIO bucket to store Litestream replication data.

- `minio_backup_bucket`: `(string: <required>)` - The MinIO bucket to store Restic backups.

- `minio_use_ssl`: `(bool: <optional>)` - Whether to use SSL to connect to MinIO. Defaults to `false`.

- `minio_checksum_algorithm`: `(string: <optional>)` - The checksum algorithm to use.

- `restic_password`: `(string: <required>)` - The password to encrypt Restic backups.

- `backup_schedule`: `(string: <optional>)` - The cron schedule to run Restic backups. Defaults to `*/5 * * * *`.
