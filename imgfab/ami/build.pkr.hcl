packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

build {
  sources = [
    // "source.qemu.nixos",
    "source.null.debian",
    "source.null.flatcar",
    "source.null.alma",
    "source.null.talos"
  ]
  provisioner "shell-local" {
    only = ["null.debian", "null.flatcar", "null.alma", "null.talos"]
    inline = [
      "mkdir -p mirror",
      "cd mirror",
      "curl -Lo ${source.name}.img ${local.distros[source.name].qemu.url}",
      "rclone copy ${source.name}.img r2:artifact/ami/"
    ]
    environment_vars = local.rclone_s3_config
  }

  provisioner "shell-local" {
    only = ["null.flatcar"]
    inline = [
      "mkdir -p mirror",
      "cd mirror",
      "curl -Lo ${source.name}.proxmox.img ${local.distros[source.name].proxmox.url}",
      "rclone copy ${source.name}.proxmox.img r2:artifact/ami/"
    ]
    environment_vars = local.rclone_s3_config
  }

  post-processor "shell-local" {
    only = ["null.debian", "null.flatcar", "null.alma", "null.talos"]
    inline = [
      "sha256sum mirror/*.img | tee SHA256SUMS",
      "rclone copy SHA256SUMS r2:artifact/ami/",
    ]
    environment_vars = local.rclone_s3_config
  }

  post-processor "shell-local" {
    inline = ["rclone copy build/${source.name}.qcow2 r2:artifact/ami/"]
    only   = ["source.qemu.nixos"]
    environment_vars = local.rclone_s3_config
  }
}

data "http" "supplychain" {
  url = "https://artifact.narwhl.dev/upstream/current.json"
}

locals {
  distros = jsondecode(data.http.supplychain.body).distros
  nixos_boot_command = [
    "sudo -i<enter><wait>",
    "parted /dev/sda -- mklabel gpt<enter><wait>",
    "parted /dev/sda -- mkpart primary 512MiB -8GiB<enter><wait>",
    "parted /dev/sda -- mkpart primary linux-swap -8GiB 100%<enter><wait>",
    "parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB<enter><wait>",
    "parted /dev/sda -- set 3 esp on<enter><wait>",
    "mkfs.ext4 -L NIXROOT /dev/sda1<enter><wait>",
    "mkswap -L swap /dev/sda2<enter><wait>",
    "mkfs.fat -F 32 -n NIXBOOT /dev/sda3<enter><wait>",
    "mount /dev/disk/by-label/NIXROOT /mnt<enter><wait>",
    "mkdir -p /mnt/boot<enter><wait>",
    "mount /dev/disk/by-label/NIXBOOT /mnt/boot<enter><wait>",
    "nixos-generate-config --root /mnt<enter><wait>",
    "mkdir -p /media && mount /dev/sr1 /media <enter><wait>",
    "cp /media/configuration.nix /mnt/etc/nixos/configuration.nix<enter><wait>",
    "nixos-install --no-root-passwd && reboot<enter>"
  ]
}
