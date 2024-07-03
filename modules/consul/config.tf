data "http" "upstream" {
  url = var.supplychain
}

locals {
  pkgs = {
    for pkg in ["consul"] : pkg => jsondecode(data.http.upstream.response_body).syspkgs[pkg]
  }
}

locals {
  users = [
    {
      name     = "consul"
      home_dir = var.data_dir
    }
  ]
  repositories = [
    "hashicorp"
  ]
  packages = [
    "consul"
  ]
}

locals {
  configs = [
    {
      path    = "/etc/consul.d/consul.env"
      tags    = "cloud-init,ignition"
      owner   = var.consul_user
      group   = var.consul_group
      content = ""
    },
    {
      path    = "/etc/consul.d/consul.hcl"
      tags    = "cloud-init,ignition"
      content = file("${path.module}/templates/consul.hcl.tftpl")
      owner   = var.consul_user
      group   = var.consul_group
    },
    {
      path = "/etc/consul.d/client.hcl"
      tags = "cloud-init,ignition"
      content = templatefile(
        "${path.module}/templates/client.hcl.tftpl",
        {
          datacenter_name = var.datacenter_name
          data_dir        = var.data_dir
          retry_join      = jsonencode(var.retry_join)
          log_level       = var.log_level
          gossip_key      = var.gossip_key
        }
      )
      owner = var.consul_user
      group = var.consul_group
    },
    {
      path = "/etc/consul.d/server.hcl"
      tags = "cloud-init,ignition"
      content = templatefile(
        "${path.module}/templates/server.hcl.tftpl",
        {
          bootstrap_expect = var.bootstrap_expect
        }
      )
      enabled = strcontains(var.role, "server")
      owner   = var.consul_user
      group   = var.consul_group
    },
    {
      path = "/etc/consul.d/encryption.hcl"
      tags = "cloud-init,ignition"
      content = templatefile(
        "${path.module}/templates/encryption.hcl.tftpl",
        {
          tls_credentials = merge(
            {
              ca_file = var.tls.ca_cert.path
            },
            local.server_tls_keypair
          )
        }
      ),
      enabled = 0 < sum([for value in values(var.tls).*.content : length(value)])
      owner   = var.consul_user
      group   = var.consul_group
    },
    {
      path    = "/etc/profile.d/consul.sh"
      tags    = "cloud-init,ignition"
      content = file("${path.module}/templates/consul.sh.tftpl")
      enabled = true
    },
    {
      path    = "/etc/systemd/resolved.conf.d/consul.conf"
      tags    = "cloud-init,ignition"
      content = file("${path.module}/templates/consul.conf.tftpl")
      enabled = var.resolve_consul_domains
    }
  ]

  directories = [
    {
      path  = "/etc/consul.d",
      owner = var.consul_user
      group = var.consul_group
    },
    {
      path  = var.data_dir
      owner = var.consul_user
      group = var.consul_group
    },
    {
      path  = "${var.data_dir}/data"
      owner = var.consul_user
      group = var.consul_group
    },
    {
      path  = "${var.data_dir}/tls"
      owner = var.consul_user
      group = var.consul_group
    }
  ]

  systemd_units = [
    {
      name = "consul-watcher.service"
      content = templatefile(
        "${path.module}/templates/watcher.service.tftpl", {
          package = "consul"
          service = "consul"
        }
      )
    },
    {
      name = "consul-watcher.path"
      content = templatefile(
        "${path.module}/templates/watcher.path.tftpl",
        {
          path    = "/usr/bin/consul"
          service = "consul-watcher.service"
        }
      )
    },
  ]
}
