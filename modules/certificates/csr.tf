resource "tls_cert_request" "clients" {
  for_each = local.clients

  private_key_pem = tls_private_key.clients[each.key].private_key_pem

  subject {
    common_name = each.key
  }
}

resource "tls_cert_request" "servers" {
  for_each = local.servers

  private_key_pem = tls_private_key.servers[each.key].private_key_pem

  dns_names    = each.value.dns_names
  ip_addresses = each.value.ip_addresses
  subject {
    common_name = each.key
  }
}