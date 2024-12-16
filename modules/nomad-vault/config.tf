data "http" "upstream" {
  url = var.supplychain
}

locals {
  pkgs = jsondecode(data.http.upstream.response_body).syspkgs
}
