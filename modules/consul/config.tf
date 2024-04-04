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
  apt = {
    repositories = [
      "hashicorp"
    ]
    packages = [
      "consul"
    ]
  }
}

locals {
  configs = [
    {
      path    = "/etc/consul.d/consul.env"
      owner   = "consul"
      group   = "consul"
      content = ""
    },
    {
      path    = "/etc/consul.d/consul.hcl"
      content = file("${path.module}/templates/consul.hcl.tftpl")
      owner   = "consul"
      group   = "consul"
    },
    {
      path = "/etc/consul.d/client.hcl"
      content = templatefile(
        "${path.module}/templates/client.hcl.tftpl",
        {
          datacenter_name = var.datacenter_name
          data_dir        = var.data_dir
          retry_join      = jsonencode(var.retry_join)
          log_level       = var.log_level
        }
      )
      owner = "consul"
      group = "consul"
    },
    {
      path = "/etc/consul.d/server.hcl"
      content = templatefile(
        "${path.module}/templates/server.hcl.tftpl",
        {
          bootstrap_expect = var.bootstrap_expect
          gossip_key       = local.gossip_key
        }
      )
      enabled = strcontains(var.role, "server")
      owner   = "consul"
      group   = "consul"
    },
    {
      path = "/etc/consul.d/encryption.hcl"
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
      owner   = "consul"
      group   = "consul"
    },
    {
      path    = "/etc/systemd/resolved.conf.d/consul.conf"
      content = file("${path.module}/templates/consul.conf.tftpl")
      enabled = var.resolve_consul_domains
    }
  ]

  directories = [
    {
      path  = "/etc/consul.d",
      owner = "consul"
      group = "consul"
    },
    {
      path  = var.data_dir
      owner = "consul"
      group = "consul"
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
