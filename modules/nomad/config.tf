data "http" "upstream" {
  url = var.supplychain
}

locals {
  pkgs = {
    for pkg in ["nomad", "cni-plugins"] : pkg => jsondecode(data.http.upstream.response_body).syspkgs[pkg]
  }
  # Default to recommendation from Nomad docs, root if client, nomad if server.
  # https://developer.hashicorp.com/nomad/docs/operations/nomad-agent#permissions
  nomad_user  = var.nomad_user == "" ? (var.role == "server" ? "nomad" : "root") : var.nomad_user
  nomad_group = var.nomad_group == "" ? (var.role == "server" ? "nomad" : "root") : var.nomad_group
}

locals {
  users = [
    {
      name     = "nomad"
      home_dir = var.data_dir
    }
  ]
  repositories = [
    "hashicorp"
  ]
  packages = [
    "nomad",
  ]
}

locals {
  configs = [
    {
      path    = "/etc/nomad.d/nomad.env"
      tags    = "cloud-init,ignition"
      owner   = local.nomad_user
      group   = local.nomad_group
      content = ""
    },
    {
      # override the default nomad.hcl config from package
      path    = "/etc/nomad.d/nomad.hcl"
      tags    = "cloud-init"
      owner   = local.nomad_user
      group   = local.nomad_group
      content = ""
    },
    {
      path    = "/etc/nomad.d/plugins.hcl"
      tags    = "cloud-init,ignition"
      owner   = local.nomad_user
      group   = local.nomad_group
      content = file("${path.module}/templates/plugins.hcl.tftpl")
    },
    {
      path    = "/etc/nomad.d/server.hcl"
      tags    = "cloud-init,ignition"
      enabled = strcontains(var.role, "server")
      owner   = local.nomad_user
      group   = local.nomad_group
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
      owner = local.nomad_user
      group = local.nomad_group
      content = templatefile(
        "${path.module}/templates/client.hcl.tftpl",
        {
          datacenter_name = var.datacenter_name
          data_dir        = var.data_dir
          log_level       = var.log_level
          host_volumes    = var.host_volume
          advertise_addr  = var.advertise_addr
          listen_addr     = var.listen_addr
          enabled         = !var.disable_client
          client_meta     = var.client_meta
        }
      )
    },
    {
      path    = "/etc/nomad.d/tls.hcl"
      enabled = var.tls.enable
      tags    = "cloud-init,ignition"
      owner   = local.nomad_user
      group   = local.nomad_group
      content = var.tls.enable ? templatefile(
        "${path.module}/templates/tls.hcl.tftpl",
        {
          tls_credentials = {
            ca_file   = var.tls.ca_file.path
            cert_file = var.tls.cert_file.path
            key_file  = var.tls.key_file.path
          }
        }
      ) : ""
    },
    {
      path    = "/etc/profile.d/nomad.sh"
      enabled = true
      tags    = "cloud-init,ignition"
      content = templatefile("${path.module}/templates/nomad.sh.tftpl", {
        protocol = var.tls.enable ? "https" : "http"
        tls_configs = var.tls.enable ? [{
          ca_file_path   = var.tls.ca_file.path
          cert_file_path = var.tls.cert_file.path
          key_file_path  = var.tls.key_file.path
        }] : []
      })
      mode = "755"
    }
  ]

  directories = concat([
    {
      path  = "/etc/nomad.d"
      owner = local.nomad_user
      group = local.nomad_group
    },
    {
      path  = var.data_dir
      owner = local.nomad_user
      group = local.nomad_group
    },
    {
      path  = "${var.data_dir}/data"
      owner = local.nomad_user
      group = local.nomad_group
    },
    {
      path  = "${var.data_dir}/tls"
      owner = local.nomad_user
      group = local.nomad_group
    }
    ], [
    for key, item in var.host_volume : {
      path  = item.path
      owner = local.nomad_user
      group = local.nomad_group
      tags  = "cloud-init,ignition"
    } if item.create_directory
  ])

  systemd_units = [
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
}
