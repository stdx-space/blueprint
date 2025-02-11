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

## Outputs
