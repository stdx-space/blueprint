output "kratos_cookie_secret" {
  value = random_bytes.kratos_cookie_secret.hex
}
