# Nomad NFS CSI

### Usage

```
module "nfs-csi" {
  source                 = "registry.narwhl.workers.dev/plugins/nfs/nomad"
  datacenter_name        = "dc0"
  nfs_csi_driver_version = "v4.1.0" # defaults to 'latest'
  nfs_server_address     = "192.168.0.1"
  nfs_share_name         = "/mnt/share"
  volumes = [
    {
      name = "ingress"
      directory = "ingress"
      permission = "766"
    }
  ]
}
```

## Argument Reference

- `datacenter_name`: `(string: <required>)` - The name of the Nomad datacenter to use.

- `plugin_id`: `(string: <optional>)` - The ID of the plugin.

- `nfs_csi_driver_version`: `(string: <optional>)` - The version of the NFS CSI driver to use.

- `nfs_server_address`: `(string: <required>)` - The address of the NFS server.

- `nfs_share_name`: `(string: <required>)` - The name of the NFS share.

- `volumes`: `([]object: <required>)` - List of volumes to mount.

### Nested Schema for `volumes`

- `name`: `(string: <required>)` - Name of the volume.

- `directory`: `(string: <required>)` - Directory to mount the volume.

- `permission`: `(string: <optional>)` - Permission of the volume, defaults to `755`.
