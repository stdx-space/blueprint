resource "proxmox_virtual_environment_file" "provisioning_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node
  source_raw {
    data = var.provisioning_config.payload
    file_name = format(
      "%s.%s",
      sha256(var.provisioning_config.payload),
      local.provisioning_config_file_format
    )
  }
}

resource "proxmox_virtual_environment_file" "network_data" {
  count        = length(var.network_data_config) > 0? 1:0
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node
  source_raw {
    data = var.network_data_config
    file_name = format(
      "%s.%s",
      sha256(var.network_data_config),
      "yml"
    )
  }
}

resource "proxmox_virtual_environment_file" "meta_data" {
  count        = length(var.meta_data_config) > 0? 1:0
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node
  source_raw {
    data = var.meta_data_config
    file_name = format(
      "%s.%s",
      sha256(var.meta_data_config),
      "yml"
    )
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = var.name
  node_name = var.node

  agent {
    enabled = var.qemu_agent_enabled
  }

  bios    = local.boot_mode
  machine = local.machine

  kvm_arguments = local.kvm_arguments

  cpu {
    architecture = "x86_64"
    cores        = var.vcpus
    type         = "host"
  }

  memory {
    dedicated = var.memory
  }

  scsi_hardware = "virtio-scsi-single"

  dynamic "efi_disk" {
    for_each = local.efi_disk
    content {
      datastore_id      = var.storage_pool
      file_format       = "raw"
      type              = "4m"
      pre_enrolled_keys = false
    }
  }

  dynamic "disk" {
    for_each = {
      for index, disk in local.disks : format("scsi%d", index) => disk
    }
    content {
      datastore_id = disk.value.storage_id
      size         = disk.value.size
      interface    = disk.key
      file_id      = endswith(disk.key, "0") ? var.os_template_id : ""
      discard      = disk.value.thin_provisioned
    }
  }

  dynamic "network_device" {
    for_each = {
      for index, network in var.networks : "network${index}" => network.id
    }
    content {
      bridge = network_device.value
    }
  }

  operating_system {
    type = "l26"
  }

  dynamic "hostpci" {
    for_each = {
      for index, device_name in var.passthrough_devices : "hostpci${index}" => device_name
    }
    content {
      device  = hostpci.key
      mapping = hostpci.value
    }
  }

  serial_device {}

  dynamic "initialization" {
    for_each = local.initialization
    content {
      interface = local.cloudinit_drive_interface[var.firmware]
      user_data_file_id    = proxmox_virtual_environment_file.provisioning_config.id
      network_data_file_id = length(var.network_data_config)>0?proxmox_virtual_environment_file.network_data.id:""
      meta_data_file_id    = length(var.meta_data_config)>0?proxmox_virtual_environment_file.meta_data.id:""
    }
  }

  lifecycle {
    replace_triggered_by = [
      proxmox_virtual_environment_file.provisioning_config
    ]
  }
}
