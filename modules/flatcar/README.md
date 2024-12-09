# Terraform module for configuring Flatcar Linux with Ignition

## Usage

```hcl
module "flatcar" {
  source              = "registry.narwhl.workers.dev/os/flatcar/ignition"
  name                = "hostname"
  ssh_authorized_keys = [tls.private_key.this.public_key_openssh]
}
```

### Variables

`name`: Hostname for the Flatcar instance.

`username`: Username for logging into the Flatcar instance, defaults to `core`.

`autologin`: Whether to enable autologin for the Flatcar instance, defaults to `true`.

`disable_ssh`: Option to disable SSH access to the Flatcar instance, defaults to `false`.

`timezone`: Timezone the VM resides in (e.g `Europe/Stockholm`), defaults to `Asia/Hong_Kong`.

`disks`: List of disks to mount onto the Flatcar instance

- `label`: Label for the disk storage device
- `mount_path`: Filesystem path to mount the disk storage device to
- `device_path`: Path to the disk storage device, e.g /dev/sda1

`expose_docker_socket`: Whether to enable docker socket to be accessible via a TCP listener, defaults to `false`.

`network`: (optional) CIDR notation for the network to be used for the Flatcar instance, e.g `10.0.0.0/16`.

`ip_address`: (optional) Static IP address to assign to the Flatcar instance, e.g `10.0.0.10`.

`gateway_ip`: (optional) Gateway IP address to assign to the Flatcar instance, e.g `10.0.0.1`.

`nameservers`: (optional) List of nameservers to assign to the Flatcar instance, e.g `["8.8.8.8", "1.1.1.1"]`.

`ca_certs`: (optional) List of CA certificates to be trusted by the Flatcar instance, either passes base64 encoded content or http url to the certificate.

`substrates`: List of configurations to be layer on top of Flatcar.

`base64_encode`: Whether to encode the resulting ignition config file in base64, defaults to `false`.

`ssh_keys_import`: List of urls that points to your ssh public keys, support fetching over git hosting provider, e.g `https://github.com/{user}.keys`, defaults to `[]`.

`ssh_authorized_keys`: A list of SSH public keys to be added to the Flatcar instance login user.
