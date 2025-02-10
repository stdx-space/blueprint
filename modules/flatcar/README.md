# Terraform module for configuring Flatcar Linux with Ignition

## Usage

```hcl
module "flatcar" {
  source              = "registry.narwhl.workers.dev/os/flatcar/ignition"
  name                = "hostname"
  ssh_authorized_keys = [tls.private_key.this.public_key_openssh]
}
```

## Argument Reference

- `name`: `(string: <required>)` - Hostname for the Flatcar instance.

- `username`: `(string: "core")` - Username for logging into the Flatcar instance, defaults to `core`.

- `autologin`: `(bool: false)` - Whether to enable autologin for the Flatcar instance, defaults to `true`.

- `disable_ssh`: `bool: <optional>` - Option to disable SSH access to the Flatcar instance, defaults to `false`.

- `timezone`: `(string: <optional>)` - Timezone the VM resides in (e.g `Europe/Stockholm`), defaults to `Asia/Hong_Kong`.

- `mounts`: `([]object: <optional>)` -  List of disks to mount onto the Flatcar instance

  - `label`: Label for the disk storage device
  - `path`: Filesystem path to mount the disk storage device to
  - `partition`: Path to the disk storage device, e.g /dev/sda1

- `expose_docker_socket`: `(bool: false)` Whether to enable docker socket to be accessible via a TCP listener.

- `expose_metrics`: Whether to enable prometheus node-exporter as systemd service container, defaults to `false`.

- `network`: `(string: <optional>)` - CIDR notation for the network to be used for the Flatcar instance, e.g `10.0.0.0/16`.

- `ip_address`: `(string: <optional>)` - Static IP address to assign to the Flatcar instance, e.g `10.0.0.10`.

- `gateway_ip`: `(string: <optional>)` - Gateway IP address to assign to the Flatcar instance, e.g `10.0.0.1`.

- `nameservers`: `(string: <optional>)` - List of nameservers to assign to the Flatcar instance, e.g `["8.8.8.8", "1.1.1.1"]`.

- `ca_certs`: `([]string: <optional>)` - List of CA certificates to be trusted by the Flatcar instance, either passes base64 encoded content or http url to the certificate.

- `substrates`: `([]object)` List of configurations to be layer on top of Flatcar.

- `base64_encode`: `(bool: false)` Whether to encode the resulting ignition config file in base64, defaults to `false`.

- `ssh_keys_import`: `([]string)` List of urls that points to your ssh public keys, support fetching over git hosting provider, e.g `https://github.com/{user}.keys`, defaults to `[]`.

- `ssh_authorized_keys`: `([]string)` A list of SSH public keys to be added to the Flatcar instance login user.

## Outputs

- `config`

- 