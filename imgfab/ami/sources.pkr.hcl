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

source "null" "talos" {
  communicator = "none"
}

source "null" "finalizer" {
  communicator = "none"
}