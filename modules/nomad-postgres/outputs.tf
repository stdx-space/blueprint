output "postgres_passwords" {
  value = merge({
    superuser = local.postgres_superuser_password
    }, {
    for db in local.postgres_init_result : db.user => db.password if db.create_user
  })
  sensitive   = true
  description = "The PostgreSQL passwords generated"
}
