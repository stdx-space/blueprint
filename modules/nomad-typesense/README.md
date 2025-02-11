# Terraform module for self hosting Typesense on Nomad

## Usage

```hcl
module "typesense" {
  source                = "registry.narwhl.workers.dev/stack/typesense/nomad"
  datacenter_name       = local.datacenter_name      # Nomad datacenter name
  typesense_version     = "26.0"                     # Typesense version
  typesense_api_key     = "<your-typesense-api-key>" # Typesense API key
  enable_ephemeral_disk = true                       # Enable Nomad ephemeral disk for the storing typesense data temporarily. Cannot be used with host volumes.
  purge_on_destroy      = true                       # Purge Typesense job on destroy
}
```

### Host volumes

One may use host volumes for persisting typesense data.

```hcl
module "typesense" {
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
  path      = "/opt/typesense/data"
  read_only = false
}
```

## Argument Reference

- `datacenter_name`: `(string: <required>)` - The name of the Nomad datacenter to use.

- `namespace`: `(string: <optional>)` - The namespace to run the job in. Defaults to `default`.

- `job_name`: `(string: <optional>)` - The name of the job. Defaults to `typesense`.

- `typesense_version`: `(string: <optional>)` - The version of Typesense to run. Defaults to `latest`.

- `typesense_api_key`: `(string: <required>)` - The Typesense API key, Defaults to randomly generated.

- `host_volume_config`: `(object: <optional>)` - The host volume configuration.

- `enable_ephemeral_disk`: `(bool: <optional>)` - Enable Nomad ephemeral disk for the storing typesense data temporarily. Cannot be used with host volumes.

- `purge_on_destroy`: `(bool: <optional>)` - Whether to purge the job on destroy. Defaults to `false`.

- `resources`: `(object: <optional>)` - The resources to allocate to the job.

### Nested Schema for `host_volume_config`

- `source`: `(string: <required>)` - The name of the host volume.

- `read_only`: `(bool: <optional>)` - Whether the volume is read-only. Defaults to `false`.

## Outputs
