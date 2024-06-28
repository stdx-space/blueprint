output "postgres_passwords" {
  value = merge({
    superuser = random_password.postgres_superuser_password.result
    }, {
    for db in local.postgres_init_result : db.user => db.password
  })
  sensitive   = true
  description = "The PostgreSQL passwords generated"
}