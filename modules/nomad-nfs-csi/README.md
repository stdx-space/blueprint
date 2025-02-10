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