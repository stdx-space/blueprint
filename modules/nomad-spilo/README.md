# Terraform module for running Spilo HA PostgreSQL on Nomad

## Usage

```terraform
module "nomad_postgres" {
  source = "github.com/narwhl/blueprint//modules/nomad-spilo"
  datacenter_name = "dc1"

}
```

## Service Discovery

This module only allows using `consul` for service discovery. As `nomad`
service discovery returns all services instead of only healthy services.

https://github.com/hashicorp/nomad/issues/23317#issuecomment-2189917446

This module relies on health checking to determine the leader of the
postgres cluster. Without health checking, it is not possible to
determine which node is writable.

All instances are registered as Consul `postgres-ro` service and the
leader is registered as `postgres-rw` service.

## Argument Reference

- `datacenter_name`: `(string: <required>)` - The name of the Nomad datacenter to use.

- `namespace`: `(string: <optional>)` - The namespace to run the job in. Defaults to `default`.

- `job_name`: `(string: <optional>)` - The name of the job. Defaults to `spilo`.

- `postgres_init_job_name`: `(string: <optional>)` - The name of the job to initialize the postgres cluster. Defaults to `spilo-init`.

- `spilo_version`: `(string: <optional>)` - The version of Spilo to run. Defaults to `latest`.

- `nodes`: `([]string: <required>)` - The list of nodes to run the job on.

- `s3_config`: `(object: <required>)` - The S3 configuration for Spilo.

- `postgres_superuser_username`: `(string: <optional>)` - The user for the postgres superuser. Defaults to `postgres`.

- `postgres_superuser_password`: `(string: <required>)` - The password for the postgres superuser.

- `postgres_init`: `([]object)` - The list of postgres instances to initialize.

- `postgres_init_script`: `(string: <optional>)` - The script to initialize the postgres cluster.

- `backup_schedule`: `(object: <optional>)` - The backup schedule for Spilo.

- `purge_on_destroy`: `(bool: <optional>)` - Whether to purge the job on destroy. Defaults to `false`.
