# Terraform module for self hosting Valkey on Nomad

## Usage

```hcl
module "valkey" {
  source                = "registry.narwhl.workers.dev/stack/valkey/nomad"
  datacenter_name       = local.datacenter_name # Nomad datacenter name
  valkey_version        = "8"                   # Valkey version
  enable_ephemeral_disk = true                  # Enable Nomad ephemeral disk for the storing valkey data temporarily. Cannot be used with host volumes.
  purge_on_destroy      = true                  # Purge Valkey job on destroy
}
```

### Persistent data

To enable persistent data, provide persistent volume configuration.

```hcl
module "valkey" {
...
  persistent_config = {
    save_options = "60 1000" # dump the dataset to disk every 60 seconds if at least 1000 keys changed
  }
}
```

The data will be persisted to `/data`. One may mount host volumes to `/data`
for persisting valkey data.

```hcl
module "valkey" {
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
  path      = "/opt/valkey/data"
  read_only = false
}
```

Alternatively, you may use the `enable_ephemeral_disk` to enable ephemeral disk
for storing valkey snapshots temporarily.

```hcl
module "valkey" {
...
  enable_ephemeral_disk = true # Enable Nomad ephemeral disk for the storing valkey data temporarily. Cannot be used with host volumes.
}
```
