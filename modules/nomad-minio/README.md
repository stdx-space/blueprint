# Terraform module for running MinIO on Nomad

This module deploys MinIO on Nomad with support for three storage modes: **ephemeral storage**, **static host volumes**, and **dynamic host volumes**.

## Usage

### Basic Usage (Ephemeral Storage)

```hcl
module "nomad_minio" {
  source          = "registry.narwhl.workers.dev/stack/minio/nomad"
  datacenter_name = "dc1"
  minio_hostname  = "files.example.app"
}
```

### Static Host Volume

```hcl
module "nomad_minio" {
  source          = "registry.narwhl.workers.dev/stack/minio/nomad"
  datacenter_name = "dc1"
  minio_hostname  = "files.example.app"

  host_volume_config = {
    source    = "minio-data"
    read_only = false
  }
}
```

### Dynamic Host Volume

```hcl
module "nomad_minio" {
  source          = "registry.narwhl.workers.dev/stack/minio/nomad"
  datacenter_name = "dc1"
  minio_hostname  = "files.example.app"

  dynamic_host_volume_config = {
    name         = "minio-data"
    plugin_id    = "host-volume"
    node_pool    = "default"
    capacity_min = "10GB"
    capacity_max = "100GB"
    parameters = {
      type = "ext4"
    }
    capability = {
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }
  }
}
```

## Storage Modes

**Ephemeral Storage** (Default) - Container-local storage, data lost on restart. Ideal for testing.

**Static Host Volumes** - Pre-provisioned host storage with manual management. Data persists across restarts.

**Dynamic Host Volumes** - CSI-based automatic provisioning with configurable capacity and node pool targeting.

## Volume Configuration Rules

- **Mutual Exclusion**: Only one of `host_volume_config` OR `dynamic_host_volume_config` can be specified
- **Ephemeral Mode**: Set both variables to `null` for container-local storage
- **Validation**: Terraform validation prevents conflicting volume configurations

## Argument Reference

### Required

`datacenter_name`: `(string: "dc1")` - The name of the Nomad datacenter to use.

### Optional

`namespace`: `(string: "default")` - The Nomad namespace to deploy to.

`job_name`: `(string: "minio")` - The name of the Nomad job.

`minio_hostname`: `(string: "minio.localhost")` - The hostname of the MinIO server.

`minio_superuser_name`: `(string: "minio")` - The name of the MinIO superuser.

`minio_superuser_password`: `(string: "")` - The password of the MinIO superuser. If not set and `generate_superuser_password` is false, an empty password is used.

`generate_superuser_password`: `(bool: false)` - Whether to generate a random MinIO superuser password.

`create_buckets`: `(list(object): [])` - List of S3 buckets to create during deployment.

`host_volume_config`: `(object: null)` - Static host volume configuration.

```hcl
host_volume_config = {
  source    = "minio-data"  # (string) Host volume source name
  read_only = false         # (bool: false) Whether volume is read-only
}
```

`dynamic_host_volume_config`: `(object: null)` - Dynamic host volume configuration.

```hcl
dynamic_host_volume_config = {
  name         = "minio-data"           # (string) Volume name
  plugin_id    = "host-volume"          # (string: "") CSI plugin ID
  node_pool    = "default"              # (string: "") Target node pool
  capacity_min = "10GB"                 # (string: "") Minimum capacity
  capacity_max = "100GB"                # (string: "") Maximum capacity
  parameters = {                        # (map: {}) Plugin parameters
    type = "ext4"
  }
  capability = {                        # (object: null) Volume capabilities
    access_mode     = "single-node-writer"  # (string: "single-node-writer")
    attachment_mode = "file-system"         # (string: "file-system")
  }
}
```

`resources`: `(object: {cpu: 1000, memory: 2048})` - Resource allocation for the MinIO task.

`purge_on_destroy`: `(bool: false)` - Whether to purge the Nomad job on destroy.

`service_discovery_provider`: `(string: "consul")` - Service discovery provider. Must be one of: `nomad`, `consul`, `consul-connect`.

`enable_https`: `(bool: false)` - Whether HTTPS proxy should be enabled.

`traefik_entrypoint`: `(object: {http: "http", https: "https"})` - Traefik entrypoint configuration.

## Outputs

`credentials`: `(object)` - MinIO superuser credentials.

### Nested Schema for `credentials`

- `access_key_id`: `(string)` - MinIO access key ID.

- `secret_access_key`: `(string)` - MinIO secret access key.


