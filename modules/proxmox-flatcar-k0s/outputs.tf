output "ssh_private_key" {
  value = tls_private_key.this.private_key_pem
}

output "ssh_public_key" {
  value = tls_private_key.this.public_key_pem
}

output "kubeconfig" {
  value = k0s_cluster.this.kubeconfig
}
