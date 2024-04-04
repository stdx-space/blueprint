data "external" "openssl" {
  program = ["bash", "-c", "openssl x509 -in <(jq -r '.root_ca_pem') -noout -fingerprint -sha256 | tr '[:upper:]' '[:lower:]' | sed s/'sha256 fingerprint='// | sed s/://g | jq --raw-input '{\"fingerprint\": .}'"]
  query = {
    root_ca_pem = trimspace(tls_self_signed_cert.root_ca.cert_pem)
  }
}

output "keychain" {
  value = {
    root_ca_cert               = tls_self_signed_cert.root_ca.cert_pem
    root_ca_private_key        = tls_private_key.root_ca.private_key_pem
    root_ca_sha256_fingerprint = data.external.openssl.result.fingerprint
    intermediate_ca_cert       = tls_locally_signed_cert.intermediate_ca.cert_pem
    intermediate_ca_key        = tls_private_key.intermediate_ca.private_key_pem

    server_keys = {
      for key in var.extra_server_certificates : key.san_dns_names[0] => tls_private_key.servers[key.san_dns_names[0]].private_key_pem
    }
    server_certificates = {
      for key in var.extra_server_certificates : key.san_dns_names[0] => tls_locally_signed_cert.servers[key.san_dns_names[0]].cert_pem
    }
  }
  sensitive = true
}
