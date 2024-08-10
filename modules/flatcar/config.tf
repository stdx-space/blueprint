data "http" "ssh_keys_import" {
  count = length(local.remote_ssh_keys)
  url   = local.remote_ssh_keys[count.index]
}

locals {
  files_contain_sensitive_data = 0 < length(var.ca_certs)
  files = concat(
    [
      {
        path    = "/etc/hostname"
        content = var.name
        enabled = true
        mode    = "644"
        owner   = "root"
        group   = "root"
      },
      {
        path    = "/etc/systemd/system/docker.service.d/override.conf"
        content = file("${path.module}/templates/docker-service-override.conf.tftpl")
        enabled = var.expose_docker_socket
        mode    = "644"
        owner   = "root"
        group   = "root"
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
      },
      {
        path    = "/opt/bin/update-restarter.sh"
        mode    = "755"
        owner   = "root"
        group   = "root"
        enabled = true
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
            "sysext.conf" = <<-EOF
              [Service]
              ExecStartPost=/opt/bin/update-restarter.sh
            EOF
          },
          {
            for package in flatten(var.substrates.*.packages) : "${package}.conf" => <<-EOF
              [Service]
              ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C ${package} update
            EOF
          }
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
