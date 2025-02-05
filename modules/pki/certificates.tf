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

  lifecycle {
    precondition {
      condition     = var.ttl > var.intermediate_ca_ttl
      error_message = "Intermediate CA TTL must be less than Root CA TTL"
    }
  }
}