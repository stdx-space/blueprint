resource "tls_private_key" "clients" {
  for_each  = local.clients
  algorithm = "RSA"
  rsa_bits  = var.bit_length
}

resource "tls_private_key" "servers" {
  for_each  = local.dns_ip_map
  algorithm = "RSA"
  rsa_bits  = var.bit_length
}