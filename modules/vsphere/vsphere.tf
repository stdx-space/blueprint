
data "vsphere_datacenter" "this" {
  name = var.datacenter
}

data "vsphere_host" "this" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_resource_pool" "this" {
  name          = "${var.host}/Resources"
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_datastore" "this" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "networks" {
  for_each      = local.networks
  name          = each.key
  datacenter_id = data.vsphere_datacenter.this.id
}

resource "terraform_data" "provisioning_config_checksum" {
  input = sha256(var.provisioning_config.payload)
}

resource "vsphere_virtual_machine" "this" {
  name = var.name

  resource_pool_id = data.vsphere_resource_pool.this.id
  host_system_id   = data.vsphere_host.this.id
  datastore_id     = data.vsphere_datastore.this.id

  firmware = var.firmware

  num_cpus = var.vcpus
  memory   = var.memory
  tags     = var.tags

  dynamic "network_interface" {
    for_each = {
      for network in var.networks : network.id => network.id
    }
    content {
      network_id = data.vsphere_network.networks[network_interface.key].id
    }
  }

  dynamic "disk" {
    for_each = {
      for index, disk in local.disks : "disk${index}" => disk
    }
    content {
      label            = disk.key
      size             = disk.value.size
      thin_provisioned = disk.value.thin_provisioned
      datastore_id     = disk.value.storage_id
    }
  }

  clone {
    template_uuid = var.os_template_id
  }

  dynamic "vapp" {
    for_each = local.vapp
    content {
      properties = local.extra_config
    }
  }

  extra_config = local.extra_config

  lifecycle {
    replace_triggered_by = [
      terraform_data.provisioning_config_checksum
    ]
  }
}
