data "http" "upstream" {
  url = var.supplychain
}

locals {
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
      path    = "/etc/consul-template.d/template.hcl"
      tags    = "cloud-init,ignition"
      owner   = "root"
      group   = "root"
      content = ""
    },
    {
      path    = "/etc/consul-template.d/config.hcl"
      tags    = "cloud-init,ignition"
      owner   = "root"
      group   = "root"
      content = ""
    }
  ]
  directories = [
    {
      path  = "/etc/consul-template.d"
      owner = "root"
      group = "root"
    },
  ]
  systemd_units = [

  ]
}