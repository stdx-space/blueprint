output "clients" {
  value = {
    for key in var.client : key.common_name => {
      cert_pem = tls_locally_signed_cert.clients[key.common_name].cert_pem
      key_pem  = tls_private_key.clients[key.common_name].private_key_pem
    }
  }
  sensitive = true
}

output "servers" {
  value = {
    for key in var.server : key.san_dns_names[0] => {
      cert_pem = tls_locally_signed_cert.servers[key.san_dns_names[0]].cert_pem
      key_pem  = tls_private_key.servers[key.san_dns_names[0]].private_key_pem
    }
  }
  sensitive = true
}