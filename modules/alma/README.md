# Terraform module for configuring Alma Linux with Cloud-Init

### Usage

```hcl
module "alma" {
  source = "github.com/narwhl/blueprint//modules/alma"
  name   = "vm-name"
}
```

`name`: Hostname for the alma instance

`username`: Username for logging into the alma instance, defaults to `system`

`password`: Password in plaintext for logging into the console, ssh login is key only.

`disks`: List of disks to mount onto the alma instance

- `label`: Label for the disk storage device
- `mount_path`: Filesystem path to mount the disk storage device to
- `device_path`: Path to the disk storage device, e.g /dev/sda1

`nameservers`: List of nameservers to assign to the Flatcar instance, e.g `["8.8.8.8", "1.1.1.1"]`

`expose_docker_socket`: Whether to enable docker socket to be accessible via a TCP listener, defaults to `false`

`ssh_authorized_keys`: A list of SSH public keys to be added to the Flatcar instance login user, support fetching over git hosting provider, e.g `https://github.com/{user}.keys`

`network`: CIDR notation for the network to be used for the Flatcar instance, e.g `10.0.0.0/16`

`ip_address`: Static IP address to assign to the Flatcar instance, e.g `10.0.0.10`

`gateway_ip`: Gateway IP address to assign to the Flatcar instance, e.g `10.0.0.1`

`timezone`: Timezone the VM resides in (e.g `Europe/Stockholm`), defaults to `Asia/Hong_Kong`

`default_packages`: A list of default packages to be installed on the alma through apt, e.g `["vim", "htop"]`

`base64_encode`: Whether to encode the resulting ignition config file in base64, defaults to `false`

### Networking

Setting static ip with Alma Linux requires to be injected from either network-data or VM's host cloud-init settings, as of this
writing, this module does not export a network-data config and it's intented to be used with proxmox module. To configure static ip, use the following setting on proxmox module:

```
module "instance" {
  source              = "github.com/narwhl/blueprint//modules/proxmox"
  name                = "vm-test"
  node                = "pve"
  vcpus               = 4
  memory              = 8192
  disk_size           = 48
  storage_pool        = "local-lvm"
  os_template_id      = proxmox_virtual_environment_download_file.alma.id
  provisioning_config = module.alma.config
  ip_address          = "192.168.1.10/24"
  gateway             = "192.168.1.1"
}
```