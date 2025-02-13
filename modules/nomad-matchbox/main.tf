resource "nomad_job" "matchbox" {
  jobspec = templatefile("${path.module}/matchbox.nomad.hcl", {
    datacenter_name    = var.datacenter_name
    dnsmasq_version    = var.dnsmasq_version
    dhcp_range_start   = var.dhcp_range[0]
    dhcp_range_end     = var.dhcp_range[1]
    matchbox_version   = var.matchbox_version
    matchbox_ipxe_url  = "${var.matchbox_url}/boot.ipxe"
    flatcar_version    = var.flatcar_version
    talos_version      = var.talos_version
    talos_schematic_id = var.talos_schematic_id
    server_cert_pem    = var.grpc_tls_cert
    server_key_pem     = var.grpc_tls_key
    root_ca_cert_pem   = var.ca_cert_pem
  })
  purge_on_destroy = true
}
