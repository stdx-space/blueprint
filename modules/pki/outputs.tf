data "external" "openssl" {
  program = ["bash", "-c", "openssl x509 -in <(jq -r '.root_ca_pem') -noout -fingerprint -sha256 | tr '[:upper:]' '[:lower:]' | sed s/'sha256 fingerprint='// | sed s/://g | jq --raw-input '{\"fingerprint\": .}'"]
  query = {
    root_ca_pem = trimspace(tls_self_signed_cert.root_ca.cert_pem)
  }
}

output "root_ca" {
  value = {
    cert_pem           = tls_self_signed_cert.root_ca.cert_pem
    key_pem            = tls_private_key.root_ca.private_key_pem
    sha256_fingerprint = data.external.openssl.result.fingerprint
  }
  sensitive = true
}

output "intermediate_ca" {
  value = {
    cert_pem = tls_locally_signed_cert.intermediate_ca.cert_pem
    key_pem  = tls_private_key.intermediate_ca.private_key_pem
  }
  sensitive = true
}
