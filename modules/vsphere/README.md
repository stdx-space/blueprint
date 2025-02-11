# Terraform module for creating vSphere VM

### Usage

```hcl
module "vsphere" {
  source = "registry.narwhl.workers.dev/hypervisor/vm/vsphere"
  name                = "vm-name"                                 # required
  vcpus               = 4                                         # optional, defaults to 1
  memory              = 4096                                      # optional, defaults to 512MBs
  disk_size           = 48                                        # optional, defaults to 16GBs
  storage_pool        = "vmpool"                                  # optional, defaults to datastore1
  os_template_id      = data.vsphere_content_library_item.item.id # required
  provisioning_config = module.os_name.config                     # required
}
```

## Argument Reference

- `name`: `(string: <required>)` - Display name for the VM in vSphere.

- `tags`: `(string: <optional>)` - Set of tags to attach to the created VM.

- `vcpus`: `(number: 1)` - Number of vCPUs to allocate to the VM.

- `memory`: `(number: 512)` - Size of memory in **_Megabytes_** to allocate to the VM, defaults to `512`.

- `disk_size`: `(number: 16)` - Size of disk space in **_Gigabytes_** to allocate to the VM, defaults to `16`.

- `disks`: `([]object: <optional>)` - A list of objects that can be optionally set to specify additional disk images to attach to the VM, this option when used is required to set the booting disk image as well and `disk_size` will be ignored if set.

  - `storage_id`: optionally set to select storage in vSphere to use for disk image, defaults to what `storage_pool` is being set
  - `size`: Size of disk space in **_Gigabytes_**
  - `thin_provisioned`: Whether preemptively preserve all disk space required by `size` or let it grow as the VM runs

- `networks`: `([]object)` - A list of objects with a property id to specify the bridging network interface to attach the VM to, defaults to `vmbr0`.

- `firemware`: `(string: "bios")` - Firmware to use for the VM, defaults to `bios`.

- `host`: `(string: <required>)` - Host to deploy the VM on, defaults to the first available host.

- `datacenter`: `(string: <required>)` - Datacenter to deploy the VM in, defaults to the first available datacenter.

- `datastore`: `(string: <optional>)` - Datastore to deploy the VM on, defaults to the first available datastore.

- `resource_pool_id`: `(string: <required>)` - Resource pool to deploy the VM in, defaults to the first available resource pool.

- `os_template_id`: `(string: <required>)` - ID of the vSphere Content Library item to use as the OS template.

- `provisioning_config`: `(object: <required>)` - Configuration object for the OS provisioning.

- `wait_for_guest_ip_timeout`: `(number: 0)` - Time in seconds to wait for the VM to get an IP address, defaults to `0`.

- `wait_for_guest_net_routable`: `(bool: false)` - Whether to wait for the VM to be routable on the network, defaults to `false`.

## Outputs

- `ip_address`: `(string)` - IP address of the VM.
