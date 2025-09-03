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

The data will be persisted to `/data`. You can use either static host volumes or dynamic host volumes for persistence.

### Dynamic Host Volumes (Recommended)

With the updated Nomad provider (2.4+), you can use dynamic host volumes that are automatically created and managed by Terraform:

```hcl
module "valkey" {
  source                = "registry.narwhl.workers.dev/stack/valkey/nomad"
  datacenter_name       = local.datacenter_name
  valkey_version        = "8"

  dynamic_host_volume_config = {
    name       = "valkey-data"
    plugin_id  = "hostpath"  # or your CSI plugin ID
    capacity_min = "1Gi"
    capacity_max = "10Gi"
    capability = {
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }
  }

  persistent_config = {
    save_options = "60 1000"
  }
}
```

### Static Host Volumes (Legacy)

For backwards compatibility, you can still use static host volumes:

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

### Ephemeral Storage

Alternatively, you may use the `enable_ephemeral_disk` to enable ephemeral disk
for storing valkey snapshots temporarily.

```hcl
module "valkey" {
...
  enable_ephemeral_disk = true # Enable Nomad ephemeral disk for the storing valkey data temporarily. Cannot be used with host volumes.
}
```

## Migration from Static to Dynamic Host Volumes

To migrate from static host volumes to dynamic host volumes:

1. Remove the `host_volume_config` variable
2. Add the `dynamic_host_volume_config` variable with appropriate settings
3. The dynamic volume will be automatically created and attached to your Valkey instance
