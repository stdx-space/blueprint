data "cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = var.base64_encode

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content = join("\n", [
      "#cloud-config",
      yamlencode(
        {
          yum_repos = local.repositories
          users     = local.users
          bootcmd = [
            "hostnamectl set-hostname ${var.name}",
            "dnf install -y gnupg ${contains(flatten(var.substrates.*.install.repositories), "nvidia-container-toolkit") ? "linux-headers-$(uname -r)" : ""}"
          ]
          cloud_init_modules = concat(
            [
              "bootcmd",
              "write_files",
              "ssh", # regenerate ssh host keys
              "users-groups",
              "growpart", # expand root partition to fill disk
              "resizefs", # resize filesystem
            ],
            0 < length(var.disks) ? ["disk_setup", "fs_setup", "mounts"] : [],
            0 < length(var.ca_certs) ? ["ca_certs"] : []
          )
          cloud_config_modules = [
            "timezone",
            "runcmd"
          ]
          cloud_final_modules = [
            "package_update_upgrade_install",
            "scripts_user", # required for runcmd
            "power_state_change"
          ]
          hostname          = var.name
          manage_etc_hosts  = true
          preserve_hostname = false
          timezone          = var.timezone
          packages          = local.packages
          ca_certs          = local.ca_certs
          disk_setup        = local.disks
          fs_setup          = local.filesystems
          write_files       = local.files
          mounts = [
            for disk in var.disks : [
              disk.device_path,
              disk.mount_path,
            ]
          ]
          runcmd = concat(
            [for dir in local.directories : "mkdir -m ${dir.mode} -p ${dir.path}"],
            [for dir in local.directories : "chown -R ${dir.owner}:${dir.group} ${dir.path}"],
            var.startup_script.override_default ? [] : [
              "dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-${local.alma_major_version}-x86_64/pgdg-redhat-repo-latest.noarch.rpm",
              "dnf -qy module disable postgresql",
              "systemctl daemon-reload",
              "systemctl enable qemu-guest-agent docker --now"
            ],
            var.startup_script.inline
          )
          power_state = {
            delay = "now"
            mode  = "reboot"
          }
        }
      )
    ])
  }
}
