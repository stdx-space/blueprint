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

