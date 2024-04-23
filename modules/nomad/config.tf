data "http" "upstream" {
  url = var.supplychain
}

locals {
  pkgs = {
    for pkg in ["nomad", "cni-plugins"] : pkg => jsondecode(data.http.upstream.response_body).syspkgs[pkg]
  }
}

locals {
  users = [
    {
      name     = "nomad"
      home_dir = var.data_dir
    }
  ]
  apt = {
    repositories = [
      "hashicorp"
    ]
    packages = [
      "nomad",
    ]
  }
}

locals {
  configs = [
    {
      path    = "/etc/nomad.d/nomad.env"
      owner   = "nomad"
      group   = "nomad"
      content = ""
    },
    {
      path    = "/etc/nomad.d/plugins.hcl"
      tags    = "cloud-init,ignition"
      owner   = "nomad"
      group   = "nomad"
      content = file("${path.module}/templates/plugins.hcl.tftpl")
    },
    {
      path    = "/etc/nomad.d/server.hcl"
      tags    = "cloud-init,ignition"
      enabled = strcontains(var.role, "server")
      owner   = "nomad"
      group   = "nomad"
      content = templatefile(
        "${path.module}/templates/server.hcl.tftpl",
        {
          bootstrap_expect = var.bootstrap_expect
          gossip_key       = local.gossip_key
        }
      )
    },
    {
      path  = "/etc/nomad.d/client.hcl"
      tags  = "cloud-init,ignition"
      owner = "nomad"
      group = "nomad"
      content = templatefile(
        "${path.module}/templates/client.hcl.tftpl",
        {
          datacenter_name = var.datacenter_name
          data_dir        = var.data_dir
          log_level       = var.log_level
        }
      )
    },
    {
      path    = "/etc/nomad.d/encryption.hcl"
      enabled = 0 < sum([for value in values(var.tls).*.content : length(value)])
      owner   = "nomad"
      group   = "nomad"
      content = templatefile(
        "${path.module}/templates/encryption.hcl.tftpl",
        {
          tls_credentials = {
            for key, item in var.tls : key => item.path
          }
        }
      )
    },
    {
      path    = "/etc/profile.d/nomad.sh"
      enabled = true
      content = file("${path.module}/templates/nomad.sh.tftpl")
      mode    = "755"
    }
  ]

  directories = [
    {
      path  = "/etc/nomad.d"
      owner = "nomad"
      group = "nomad"
    },
    {
      path  = var.data_dir
      owner = "nomad"
      group = "nomad"
    },
    {
      path  = "${var.data_dir}/data"
      owner = "nomad"
      group = "nomad"
    },
    {
      path  = "${var.data_dir}/tls"
      owner = "nomad"
      group = "nomad"
    }
  ]

  systemd_units = concat(
    [
      for pkg in keys(local.pkgs) : {
        name    = "${pkg}-sysext-img-watcher.path"
        enabled = false
        content = templatefile(
          "${path.module}/templates/watcher.path.tftpl",
          {
            path = format(
              "/etc/extensions/${pkg}-%s-x86-64.raw",
              local.pkgs[pkg].version
            )
            service = "sysext-img-reload.service"
          }
        )
      }
    ],
    [
      for pkg in keys(local.pkgs) : {
        name    = "kickstart-${pkg}-update-watcher.timer"
        content = <<-EOF
          [Unit]
          Description=Timer to kickstart update watcher for ${pkg}

          [Timer]
          OnActiveSec=1h

          [Install]
          WantedBy=timers.target
        EOF
      }
    ],
    [
      for pkg in keys(local.pkgs) : {
        name    = "kickstart-${pkg}-update-watcher.service"
        content = <<-EOF
          [Unit]
          Description=Enable sysext image path watcher for ${pkg}
          StartLimitIntervalSec=0

          [Service]
          Type=oneshot
          ExecStart=systemctl enable ${pkg}-sysext-img-watcher.path --now

          [Install]
          WantedBy=multi-user.target
        EOF
      }
    ],
    [
      {
        name = "nomad-watcher.service"
        content = templatefile(
          "${path.module}/templates/watcher.service.tftpl", {
            package = "nomad"
            service = "nomad"
          }
        )
      },
      {
        name = "nomad-watcher.path"
        content = templatefile(
          "${path.module}/templates/watcher.path.tftpl",
          {
            path    = "/usr/bin/nomad"
            service = "nomad-watcher.service"
          }
        )
      },
    ]
  )
}
