# Packer build for Debian on VMware vSphere
source "vsphere-iso" "debian" {
  vcenter_server      = var.vsphere_endpoint
  host                = var.vsphere_host
  datastore           = var.vsphere_datastore
  datacenter          = var.vsphere_datacenter
  username            = var.vsphere_username
  password            = var.vsphere_password
  insecure_connection = true

  // Virtual Machine Settings
  guest_os_type        = local.vm_guest_os_types[source.name]
  vm_name              = source.name
  CPUs                 = var.vm_cpu
  RAM                  = var.vm_mem_size
  disk_controller_type = var.vm_disk_controller_type
  storage {
    disk_size             = var.vm_disk_size
    disk_thin_provisioned = var.vm_disk_thin_provisioned
  }
  network_adapters {
    network      = var.vsphere_network
    network_card = var.vm_network_card
  }
  // Removable Media Settings
  iso_checksum = local.distros[source.name].iso.checksum
  iso_url      = local.distros[source.name].iso.url
  remove_cdrom = true

  cd_content = {
    "preseed.cfg" = templatefile("${path.root}/templates/preseed.cfg.pkrtpl", {
      "timezone" = var.timezone,
      "packages" = join(" ", [
        "apt-transport-https",
        "ca-certificates",
        "curl",
        "git",
        "gnupg",
        "open-vm-tools",
        "sudo",
        "vim",
        "cloud-init"
      ]),
      "ssh_password" = var.ssh_password
    })
  }

  // Boot and Provisioning Settings
  boot_order = var.vm_boot_order
  boot_command = [
    "<wait>",
    "<down><down><enter>",
    "<down><down><down><down><down><down><enter>",
    "<wait60s>",
    "<leftAltOn><f2><leftAltOff>",
    "<enter><wait>",
    "mount /dev/sr1 /media<enter>",
    "<leftAltOn><f1><leftAltOff>",
    "file:///media/preseed.cfg",
    "<enter><wait>"
  ]

  // Communicator Settings and Credentials
  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password

  export {
    output_directory = "${path.root}/build"
  }
}

source "vsphere-iso" "nixos" {
  vcenter_server      = var.vsphere_endpoint
  host                = var.vsphere_host
  datastore           = var.vsphere_datastore
  username            = var.vsphere_username
  password            = var.vsphere_password
  insecure_connection = true
  // Virtual Machine Settings
  guest_os_type        = local.vm_guest_os_types[source.name]
  vm_name              = source.name
  CPUs                 = var.vm_cpu
  RAM                  = var.vm_mem_size
  disk_controller_type = var.vm_disk_controller_type
  storage {
    disk_size             = var.vm_disk_size
    disk_thin_provisioned = var.vm_disk_thin_provisioned
  }
  network_adapters {
    network      = var.vsphere_network
    network_card = var.vm_network_card
  }
  // Removable Media Settings
  iso_checksum = local.distros[source.name].iso.checksum
  iso_url      = local.distros[source.name].iso.url
  remove_cdrom = true

  cd_content = {
    "configuration.nix" = templatefile("${path.root}/snippets/configuration.nix.pkrtpl", {
      "timezone"     = var.timezone,
      "ssh_password" = var.ssh_password
      "packages" = join("\n", [
        "cloud-init",
        "git",
        "gnupg",
        "vim"
      ])
    })
  }

  // Boot and Provisioning Settings
  firmware     = "efi"
  boot_wait    = "60s"
  boot_order   = var.vm_boot_order
  boot_command = local.nixos_boot_command

  // Communicator Settings and Credentials
  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password

  export {
    output_directory = "${path.root}/build"
  }
}

source "vsphere-iso" "alma" {
  vcenter_server      = var.vsphere_endpoint
  host                = var.vsphere_host
  datastore           = var.vsphere_datastore
  username            = var.vsphere_username
  password            = var.vsphere_password
  insecure_connection = true
  // Virtual Machine Settings
  guest_os_type        = local.vm_guest_os_types[source.name]
  vm_name              = source.name
  CPUs                 = var.vm_cpu
  RAM                  = var.vm_mem_size
  disk_controller_type = var.vm_disk_controller_type
  storage {
    disk_size             = var.vm_disk_size
    disk_thin_provisioned = var.vm_disk_thin_provisioned
  }
  network_adapters {
    network      = var.vsphere_network
    network_card = var.vm_network_card
  }
  // Removable Media Settings
  iso_checksum = local.distros[source.name].iso.checksum
  iso_url      = local.distros[source.name].iso.url
  remove_cdrom = true

  cd_content = {
    "ks.cfg" = templatefile("${path.root}/snippets/ks.cfg.pkrtpl", {
      "timezone"     = var.timezone,
      "ssh_password" = var.ssh_password
      "packages" = join("\n", [
        "openssh-clients",
        "curl",
        "cloud-init",
        "dnf-utils",
        "drpm",
        "net-tools",
        "open-vm-tools",
        "sudo",
        "vim",
        "python3"
      ])
    })
  }

  // Boot and Provisioning Settings
  firmware   = "efi"
  boot_wait  = "60s"
  boot_order = var.vm_boot_order
  boot_command = [
    "<up><tab> text inst.ks=cdrom:/ks.cfg<enter><wait><enter>"
  ]

  // Communicator Settings and Credentials
  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password

  export {
    output_directory = "${path.root}/build"
  }
}

source "qemu" "nixos" {
  output_directory = "${path.root}/build"
  cores            = 2
  memory           = 4096
  disk_size        = "16G"
  disk_compression = true
  headless         = true
  format           = "qcow2"
  accelerator      = "kvm"
  ssh_username     = "root"
  ssh_password     = var.ssh_password
  ssh_timeout      = "15m"
  vm_name          = "${source.name}.qcow2"
  net_device       = "virtio-net"
  disk_interface   = "virtio-scsi"
  shutdown_command = "sudo shutdown -h now"
  efi_boot         = true
  vnc_bind_address = "0.0.0.0"

  iso_url      = local.distros[source.name].iso.url
  iso_checksum = local.distros[source.name].iso.checksum
  cd_content = {
    "configuration.nix" = templatefile("${path.root}/templates/configuration.nix.pkrtpl", {
      "timezone"     = var.timezone,
      "ssh_password" = var.ssh_password
      "packages" = join("\n", [
        "cloud-init",
        "git",
        "gnupg",
        "vim"
      ])
    })
  }

  boot_wait    = "60s"
  boot_command = local.nixos_boot_command
}

source "null" "alma" {
  communicator = "none"
}

source "null" "debian" {
  communicator = "none"
}

source "null" "flatcar" {
  communicator = "none"
}
