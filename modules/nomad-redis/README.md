# Terraform module for self hosting Redis on Nomad

## Usage

```hcl
module "redis" {
  source                = "registry.narwhl.workers.dev/stack/redis/nomad"
  datacenter_name       = local.datacenter_name # Nomad datacenter name
  redis_version         = "7"                   # Redis version
  enable_ephemeral_disk = true                  # Enable Nomad ephemeral disk for the storing redis data temporarily. Cannot be used with host volumes.
  purge_on_destroy      = true                  # Purge Typesense job on destroy
}
```

### Persistent data

To enable persistent data, provide persistent volume configuration.

```hcl
module "redis" {
...
  persistent_config = {
    save_options = "60 1000" # dump the dataset to disk every 60 seconds if at least 1000 keys changed
  }
}
```

The data will be persisted to `/data`. One may mount host volumes to `/data`
for persisting typesense data.

```hcl
module "redis" {
...
  host_volume_config = {
    source = "host-volume-name"
    read_only = false
  }
}
```

Remember to update `/etc/nomad.d/nomad.hcl` configuration to create the host
volume. This should be under the `client` stanza.

```hcl
host_volume "host-volume-name" {
  path      = "/opt/redis/data"
  read_only = false
}
```

Alternatively, you may use the `enable_ephemeral_disk` to enable ephemeral disk
for storing redis snapshots temporarily.

```hcl
module "redis" {
...
  enable_ephemeral_disk = true # Enable Nomad ephemeral disk for the storing redis data temporarily. Cannot be used with host volumes.
}
```

## Argument Reference

- `datacenter_name`: `(string: <required>)` - The name of the Nomad datacenter to use.

- `namespace`: `(string: <optional>)` - The namespace to run the job in. Defaults to `default`.

- `job_name`: `(string: <optional>)` - The name of the job. Defaults to `redis`.

- `redis_version`: `(string: <optional>)` - The version of Redis to run. Defaults to `latest`.

- `host_volume_config`: `(object: <optional>)` - The host volume configuration to mount to the container.

- `enable_ephemeral_disk`: `(bool: <optional>)` - Enable Nomad ephemeral disk for the storing redis data temporarily. Cannot be used with host volumes.

- `purge_on_destroy`: `(bool: <optional>)` - Whether to purge the job on destroy. Defaults to `false`.

- `persistent_config`: `(object: <optional>)` - The persistent volume configuration to store redis data.

- `resources`: `(object: <optional>)` - The resources to allocate to the job.
