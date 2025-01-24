resource "tls_self_signed_cert" "root_ca" {

  private_key_pem = tls_private_key.root_ca.private_key_pem

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature"
  ]

  subject {
    common_name         = "${var.root_ca_common_name} Root CA"
    country             = var.country
    locality            = var.locality
    organization        = var.root_ca_org_name
    organizational_unit = var.root_ca_org_unit
  }

  validity_period_hours = var.ttl
  is_ca_certificate     = true
}

resource "tls_cert_request" "intermediate_ca" {
  private_key_pem = tls_private_key.intermediate_ca.private_key_pem

  subject {
    common_name  = "${var.root_ca_common_name} Intermediate CA"
    organization = tls_self_signed_cert.root_ca.subject[0].organization
  }
}

resource "tls_locally_signed_cert" "intermediate_ca" {
  cert_request_pem   = tls_cert_request.intermediate_ca.cert_request_pem
  ca_private_key_pem = tls_private_key.root_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca.cert_pem

  validity_period_hours = var.intermediate_ca_ttl
  is_ca_certificate     = true

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "cert_signing"
  ]
}

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

resource "tls_locally_signed_cert" "clients" {
  for_each = local.clients

  cert_request_pem   = tls_cert_request.clients[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.intermediate_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.intermediate_ca.cert_pem

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
  ca_private_key_pem = tls_private_key.intermediate_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.intermediate_ca.cert_pem

  validity_period_hours = each.value.ttl
  is_ca_certificate     = false

  allowed_uses = [
    "client_auth",
    "server_auth",
    "key_encipherment",
    "digital_signature"
  ]
}
