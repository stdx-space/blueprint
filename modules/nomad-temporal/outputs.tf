output "postgres_username" {
  value = var.postgres_username
}

output "postgres_password" {
  value = random_password.db_password.result
}