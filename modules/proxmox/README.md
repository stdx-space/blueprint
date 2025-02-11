### Terraform Module for provisioning a Proxmox VM

## Usage

### Regular VM

```hcl
module "proxmox" {
  source              = "registry.narwhl.workers.dev/hypervisor/vm/proxmox"
  name                = "vm-name"
  vcpus               = 4
  memory              = 4096                                         # optional, defaults to 512MBs
  disk_size           = 48                                           # optional, defaults to 16GBs
  storage_pool        = "local-lvm"                                  # optional, defaults to local-lvm
  os_template_id      = proxmox_virtual_environment_file.os_image.id # required
  provisioning_config = module.os_name.config                        # required
}
```

### VM with PCI-Passthrough

```hcl
module "proxmox" {
  source              = "registry.narwhl.workers.dev/hypervisor/vm/proxmox"
  name                = var.name
  node                = var.node
  firmware            = "uefi"
  vcpus               = 8
  memory              = 8192
  storage_pool        = "local-lvm"
  disk_size           = 64
  os_template_id      = var.disk_template_id
  passthrough_devices = ["gpu0"]
  provisioning_config = module.debian.config
}

```

### Variables

- `name`: `(string: <required>)` - Display name for the VM in Proxmox.

- `tags`: `(string: <optional>)` - Set of tags to attach to the created VM.

- `vcpus`: `(number: 1)` - Number of vCPUs to allocate to the VM.

- `memory`: `(number: 512)` - Size of memory in **_Megabytes_** to allocate to the VM, defaults to `512`.

- disk_size`: `(number: 16)` - Size of disk space in **_Gigabytes_** to allocate to the VM, defaults to `16`.

- `disks`: `([]object: <optional>)` - A list of objects that can be optionally set to specify additional disk images to attach to the VM, this option when used is required to set the booting disk image as well and `disk_size` will be ignored if set.

  - `storage_id`: optionally set to select storage in Proxmox to use for disk image, defaults to what `storage_pool` is being set
  - `size`: Size of disk space in **_Gigabytes_**
  - `thin_provisioned`: Whether preemptively preserve all disk space required by `size` or let it grow as the VM runs

- `storage_pool`: `(string: "local-lvm")` - Storage in Proxmox to put the VM's disk image on, defaults to `local-lvm`.

- `networks`: `([]object)` - A list of objects with a property id to specify the bridging network interface to attach the VM to, defaults to `vmbr0`.

- `node`: `(string: "pve")` - Proxmox node to deploy the VM to, defaults to `pve`.

- `snippet_stored_path`: `(string: <optional>)` - The filesystem path to stored the snippets in Proxmox.

- `qemu_agent_enabled`: `(bool: true)` - Whether to enable communication between QEMU Guest Agent within the VM to the Proxmox host node.

- `firmware`: `(string: "bios")` - Either set to `bios` or `uefi`, might required to be set to `uefi` when `passthrough_devices` is specified depending on the OS.

- `os_template_id`: `(string: <required>)` - QEMU disk image reference id stored in Proxmox's storage.

- `passthrough_devices`: `([]string: <optional>)` - Mapped hardware label in resource mapping section within Proxmox's Datacenter level setting, see more [here](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#resource_mapping).

- `provisioning_config`: `(object: <required>)` - An object with the following properties:

  - `type`: Either specified as `cloud-init` or `ignition`
  - `payload`: Content of the detailed config file

## Outputs

- `ip_address`: `(string)` - The IP address of the VM.

- `interface_name`: `([]string)` - The network interface names of the VM.
