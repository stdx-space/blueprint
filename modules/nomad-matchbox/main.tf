locals {
  nomad_var_template = "{{ with nomadVar \"nomad/jobs/${var.job_name}\" }}{{ .%s }}{{ end }}"
}

resource "nomad_variable" "matchbox" {
  path      = "nomad/jobs/${var.job_name}"
  namespace = var.namespace
  items = {
    grpc_tls_cert = var.grpc_tls_cert
    grpc_tls_key  = var.grpc_tls_key
    ca_cert_pem   = var.ca_cert_pem
  }
}

resource "nomad_job" "matchbox" {
  jobspec = templatefile("${path.module}/matchbox.nomad.hcl", {
    job_name           = var.job_name
    datacenter_name    = var.datacenter_name
    namespace          = var.namespace
    dnsmasq_version    = var.dnsmasq_version
    dhcp_range_start   = var.dhcp_range[0]
    dhcp_range_end     = var.dhcp_range[1]
    matchbox_version   = var.matchbox_version
    matchbox_ipxe_url  = "${var.matchbox_url}/boot.ipxe"
    flatcar_version    = var.flatcar_version
    talos_version      = var.talos_version
    talos_schematic_id = var.talos_schematic_id
    server_cert_pem    = format(local.nomad_var_template, "grpc_tls_cert")
    server_key_pem     = format(local.nomad_var_template, "grpc_tls_key")
    root_ca_cert_pem   = format(local.nomad_var_template, "ca_cert_pem")
  })
  purge_on_destroy = true
}
