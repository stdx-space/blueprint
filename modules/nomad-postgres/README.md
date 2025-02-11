# Terraform module for running PostgreSQL on Nomad

This module only works with Debian currently. This module assumes the
`postgresql` and `pgbackrest` packages are installed in the host Debian system.

## Usage

Below is an example of how to use this module to create a PostgreSQL cluster with backups enabled.

```terraform
module "nomad_postgres" {
  source          = "registry.narwhl.workers.dev/stack/postgres/nomad"
  datacenter_name = "dc1"
  pgbackrest_s3_config = {
    endpoint   = "https://${data.cloudflare_accounts.cf_account.accounts[0].id}.r2.cloudflarestorage.com"
    bucket     = cloudflare_r2_bucket.pgbackrest.name
    access_key = "<access_key>"
    secret_key = "<secret_key>"
    region     = "us-east-1"
  }
  backup_schedule = {
    full = {
      schedule        = "@weekly" # schedule defined in cron syntax
      retention_count = 4         # number of full backups to keep
    }
    incremental = {
      schedule = "@daily"
    }
  }
  # Do not provide restore_backup config unless performing a restore
  # restore_backup = {
  #   backup_set = "latest"
  # }
}
```

### Prerequisites

#### PostgreSQL Packages

This module assumes the `postgresql` and `pgbackrest` packages are installed in
the host Debian system. It is also required to mask the postgresql systemd job
to prevent conflicts. Reinitialize the cluster to a clean state if the
`postgresql` service has been run before.

If you are using `debian` module, you may refer to the below example.

```terraform
module "debian" {
  source = "registry.narwhl.workers.dev/os/debian/cloudinit"
  name   = "vm-name"
  ...
  additional_packages = [
    "postgresql",
    "pgbackrest"
  ]
  startup_script = {
    override_default = false
    inline = [
      "systemctl stop postgresql",
      "systemctl mask postgresql",
      "pg_dropcluster 15 main", # drop the original cluster created by debian apt install
      "pg_createcluster <postgres_version> <postgres_cluster_name> -p 5432", # initialize a new cluster to be used in nomad, note that the port must be 5432
    ]
  }
}
```

#### Nomad Host Volumes

To run `nomad-postgres` module, you need to configure 3 host volumes `postgres-data`, `postgres-socket` and
`postgres-log` mounting paths specified below and pass their volume name in `nomad-postgres` module configuration.

```terraform

module "nomad" {
  source = "registry.narwhl.workers.dev/service/nomad/systemd"
  datacenter_name = "dc1"
  role            = "server"
  host_volume     = {
    "postgres-data" = {
      path = "/var/lib/postgresql"
      read_only = false
    }
    "postgres-socket" = {
      path = "/var/run/postgresql"
      read_only = false
    }
    "postgres-log" = {
      path = "/var/log/postgresql"
      read_only = false
    }
  }
}
```

## Argument Reference

- `datacenter_name`: The name of the Nomad datacenter to use.

- `pgbackrest_s3_config`: The configuration for pgbackrest to use. If null, backups will not be enabled.

- `restore_backup`: Configuration for restoring a backup. If not null, creates a one-off restore job to restore with specified config.

## Outputs



## Backup

If backup is enabled (i.e. pgbackrest_s3_config is not null), the module will
create a periodic job to backup the cluster with pgbackrest. Apart from
periodic backups, it also updates PostgreSQL configuration to send WAL files
to the backup location for online backup.

### Schedule

The module runs 2 kinds of backups: full and incremental. The full backup
includes all data files and the incremental backup only includes incremental
changes since the last backup.

The backup schedule is configured by setting the `backup_schedule` configuration.

```terraform
module "nomad_postgres" {
  ...
  backup_schedule = {
    full = {
      schedule        = "@weekly" # schedule defined in cron syntax
      retention_count = 4         # number of full backups to keep
    }
    incremental = {
      schedule = "@daily"
    }
  }
}
```

### Restoration

WARNING: all current data is destroyed when restoring a backup.

To restore a backup, the current cluster must be stopped and all data files
must be removed. By providing the `restore_backup` configuration, the module
will remove `postgres` job to stop the cluster and spin up a one-off restore
job to restore the backup. The restore job will first remove everything in
the data directory and then restore the backup.

#### Restoration Procedure

Restoration is performed by updating the `restore_backup` configuration.
Terraform will create and destroy required Nomad jobs to restore the backup.

1. Starts restore procedure by setting `restore_backup` configuration. Provide
   the backup set to restore.
2. Apply the Terraform configuration.
3. Wait for restoration to complete (the restore task exits with 0).
4. Revert the Terraform configuration to start the restored cluster.
5. Apply the Terraform configuration.
