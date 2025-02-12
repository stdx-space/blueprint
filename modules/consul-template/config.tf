data "http" "upstream" {
  url = var.supplychain
}

locals {
  templates = {
    for template in var.templates : template.name => {
      contents    = template.contents
      destination = template.destination
      command     = jsonencode(template.command)
      owner       = template.owner
      group       = template.group
      mode        = template.mode
    }
  }
  pkgs = {
    for pkg in ["consul-template"] : pkg => jsondecode(data.http.upstream.response_body).syspkgs[pkg]
  }
  repositories = [
    "hashicorp"
  ]
  packages = [
    "consul-template",
  ]
  configs = [
    {
      path    = "/etc/sysconfig/consul-template"
      tags    = "ignition"
      owner   = "root"
      group   = "root"
      content = ""
    },
    {
      path  = "/etc/consul-template.d/template.hcl"
      tags  = "cloud-init,ignition"
      owner = "root"
      group = "root"
      content = templatefile("${path.module}/templates/template.hcl.tftpl", {
        templates = var.templates
      })
    },
    {
      path  = "/etc/consul-template.d/config.hcl"
      tags  = "cloud-init,ignition"
      owner = "root"
      group = "root"
      content = templatefile("${path.module}/templates/config.hcl.tftpl", {
        consul_address = var.consul_address
      })
    }
  ]
  directories = [
    {
      path  = "/etc/consul-template.d"
      owner = "root"
      group = "root"
    },
  ]
}
