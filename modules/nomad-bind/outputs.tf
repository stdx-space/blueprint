output "tsig_secret_key" {
  value     = random_bytes.secret.base64
  sensitive = true
}
