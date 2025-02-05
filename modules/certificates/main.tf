locals {
  dns_ip_map = {
    for key in var.server : key.san_dns_names[0] => key.san_ip_addresses
  }
  clients = { for client in var.client : client.common_name => client }
  servers = {
    for signing_request in var.server : signing_request.san_dns_names[0] => {
      dns_names    = signing_request.san_dns_names
      ip_addresses = signing_request.san_ip_addresses
      ttl          = signing_request.ttl
    }
  }
}


resource "tls_locally_signed_cert" "clients" {
  for_each = local.clients

  cert_request_pem   = tls_cert_request.clients[each.key].cert_request_pem
  ca_private_key_pem = var.ca_private_key_pem
  ca_cert_pem        = var.ca_private_key_pem

  validity_period_hours = each.value.ttl
  is_ca_certificate     = false

  allowed_uses = [
    "client_auth",
    "key_encipherment",
    "digital_signature"
  ]
}

resource "tls_locally_signed_cert" "servers" {
  for_each = local.servers

  cert_request_pem   = tls_cert_request.servers[each.key].cert_request_pem
  ca_private_key_pem = var.ca_private_key_pem
  ca_cert_pem        = var.ca_cert_pem

  validity_period_hours = each.value.ttl
  is_ca_certificate     = false

  allowed_uses = [
    "client_auth",
    "server_auth",
    "key_encipherment",
    "digital_signature"
  ]
}
