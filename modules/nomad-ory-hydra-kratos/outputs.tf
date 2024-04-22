output "postgres_root_password" {
  value = random_password.db_admin.result
}

output "hydra_db_password" {
  value = random_password.hydra_db_password.result
}

output "kratos_db_password" {
  value = random_password.kratos_db_password.result
}