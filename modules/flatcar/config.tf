data "http" "ssh_keys_import" {
  count = length(var.ssh_keys_import)
  url   = var.ssh_keys_import[count.index]
}

locals {
  files = concat(
    [
      {
        path    = "/etc/hostname"
        content = var.name
        enabled = true
        mode    = "644"
        owner   = "root"
        group   = "root"
        tags    = "ignition"
      },
      {
        path    = "/etc/systemd/system/docker.service.d/override.conf"
        content = file("${path.module}/templates/docker-service-override.conf.tftpl")
        enabled = var.expose_docker_socket
        mode    = "644"
        owner   = "root"
        group   = "root"
        tags    = "ignition"
      },
      {
        path = "/etc/systemd/network/static.network"
        content = templatefile("${path.module}/templates/static.network.tftpl", {
          ip_address  = "${var.ip_address}/${local.subnet_bits}"
          gateway_ip  = var.gateway_ip
          nameservers = var.nameservers
        })
        enabled = 0 < length(var.ip_address) && 0 < length(var.gateway_ip)
        mode    = "644"
        owner   = "root"
        group   = "root"
        tags    = "ignition"
      },
      {
        path    = "/opt/bin/update-restarter.sh"
        mode    = "755"
        owner   = "root"
        group   = "root"
        enabled = anytrue([for file in flatten(var.substrates.*.files) : strcontains(file.path, "/etc/extensions")])
        tags    = "ignition"
        content = <<-EOF
          #!/bin/bash
          set -e
          set -o pipefail
          if [ -e /opt/current.digest ]
          then
            sha256sum /etc/extensions/*-x86-64.raw > /opt/latest.digest
            if ! diff -q /opt/current.digest /opt/latest.digest &>/dev/null; then
              >&2 systemctl restart systemd-sysext
            cp /opt/latest.digest /opt/current.digest
            fi
          else
            sha256sum /etc/extensions/*-x86-64.raw > /opt/current.digest
          fi
        EOF
      },
      {
        path    = "/opt/bin/lvm.sh"
        mode    = "755"
        owner   = "root"
        group   = "root"
        enabled = length(var.lvm_volume_groups) > 0
        tags    = "ignition"
        content = <<-EOF
          #!/bin/bash
          set -euo pipefail
          groups='${jsonencode(var.lvm_volume_groups)}'
          # Iterate over each volume group in the JSON string
          for vg in $(echo "$groups" | jq -c '.[]'); do
              # Extract the name of the volume group
              vg_name=$(echo "$vg" | jq -r '.name')

              # Extract the list of devices as an array
              devices=$(echo "$vg" | jq -r '.devices | join(" ")')

              # Create physical volumes for each device
              for device in $devices; do
                  echo "Creating physical volume on $device"
                  pvcreate "$device" || { echo "Failed to create physical volume on $device"; exit 1; }
              done

              # Create the volume group
              echo "Creating volume group $vg_name with devices $devices"
              vgcreate "$vg_name" $devices || { echo "Failed to create volume group $vg_name"; exit 1; }
          done

          echo "Volume groups created successfully."
        EOF
      }
    ],
    flatten(var.substrates.*.files),
  )
  ssh_authorized_keys = distinct(concat(
    [
      for key in var.ssh_authorized_keys : key if startswith(key, "ssh")
    ],
    compact(flatten([
      for v in data.http.ssh_keys_import : split("\n", v.response_body)
    ]))
  ))
  systemd_units = concat(
    local.default_units,
    local.mount_units,
    flatten(var.substrates.*.install.systemd_units),
    [
      {
        name    = "systemd-sysupdate.timer"
        content = null
      },
      {
        name    = "systemd-sysupdate.service"
        content = null
        dropins = merge(
          {
            for package in flatten(var.substrates.*.packages) : "${package}.conf" => <<-EOF
              [Service]
              ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C ${package} update
            EOF
          },
          anytrue([for file in flatten(var.substrates.*.files) : strcontains(file.path, "/etc/extensions")]) ? {
            "sysext.conf" = <<-EOF
              [Service]
              ExecStartPost=/opt/bin/update-restarter.sh
            EOF
          } : {}
        )
      },
      {
        name    = "multi-user.target"
        content = null
        dropins = merge(
          {
            for package in flatten(var.substrates.*.packages) : "10-${package}-path-watcher.conf" => <<-EOF
                [Unit]
                Upholds=${package}-watcher.path
              EOF
          },
          {
            for package in flatten(var.substrates.*.packages) : "20-${package}-service-watcher.conf" => <<-EOF
                [Unit]
                Wants=${package}-watcher.service
              EOF
          },
        )
      },
    ]
  )
  ca_certs = [
    for ca_cert in var.ca_certs : {
      source = startswith(ca_cert, "http") ? ca_cert : "data:text/plain;charset=utf-8;base64,${base64encode(ca_cert)}"
    }
  ]
}
