output "hydra_db_password" {
  value = var.hydra_database_password == "" ? random_password.hydra_db_password[0].result : var.hydra_database_password
}

output "kratos_db_password" {
  value = var.kratos_database_password == "" ? random_password.kratos_db_password[0].result : var.kratos_database_password
}

output "kratos_cookie_secret" {
  value = random_bytes.kratos_cookie_secret.hex
}
