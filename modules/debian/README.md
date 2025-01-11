# Terraform module for configuring Debian Linux with Cloud-Init

### Usage

```hcl
module "debian" {
  source = "registry.narwhl.workers.dev/os/debian/cloudinit"
  name   = "vm-name"
}
```

`name`: Hostname for the Debian instance

`username`: Username for logging into the Debian instance, defaults to `system`

`password`: Password in plaintext for logging into the console, ssh login is key only.

`autologin`: (optional) Whether to enable autologin for the guest instance, defaults to `true`.

`disks`: List of disks to mount onto the Debian instance

- `label`: Label for the disk storage device
- `mount_path`: Filesystem path to mount the disk storage device to
- `device_path`: Path to the disk storage device, e.g /dev/sda1

`nameservers`: List of nameservers to assign to the guest instance, e.g `["8.8.8.8", "1.1.1.1"]`

`expose_docker_socket`: Whether to enable docker socket to be accessible via a TCP listener, defaults to `false`

`expose_metrics`: Whether to install and enable prometheus node-exporter as systemd service, defaults to `false`.

`ssh_keys_import`: (optional) List of urls that points to your ssh public keys, support fetching over git hosting provider, e.g `https://github.com/{user}.keys`, defaults to `[]`.

`ssh_authorized_keys`: A list of SSH public keys to be added to the Debian instance login user.

`network`: CIDR notation for the network to be used for the guest instance, e.g `10.0.0.0/16`

`ip_address`: Static IP address to assign to the guest instance, e.g `10.0.0.10`

`gateway_ip`: Gateway IP address to assign to the guest instance, e.g `10.0.0.1`

`timezone`: Timezone the VM resides in (e.g `Europe/Stockholm`), defaults to `Asia/Hong_Kong`

`default_packages`: A list of default packages to be installed on the Debian through apt, e.g `["vim", "htop"]`

`base64_encode`: Whether to encode the resulting ignition config file in base64, defaults to `false`
