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

- `datacenter_name`

- `namespace`

- `job_name`

- `typesense_version`

- `typesense_api_key`

- `host_volume_config`

- `enable_ephemeral_disk`

- `purge_on_destroy`

- `resources`

