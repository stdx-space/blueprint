# Nomad NFS CSI

### Usage

```
module "nfs-csi" {
  source                 = "git::https://gitlab.com/narwhl/wip/blueprint.git//modules/nomad-nfs-csi"
  datacenter_name        = "sight"
  nfs_csi_driver_version = "v4.1.0"
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
