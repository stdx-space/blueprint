resource "tls_private_key" "root_ca" {
  algorithm = "RSA"
  rsa_bits  = var.bit_length
}

resource "tls_private_key" "intermediate_ca" {
  algorithm = "RSA"
  rsa_bits  = var.bit_length
}

resource "tls_private_key" "servers" {
  for_each  = local.dns_ip_map
  algorithm = "RSA"
  rsa_bits  = var.bit_length
}
