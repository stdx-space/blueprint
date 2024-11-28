resource "random_password" "postgres_password" {
  for_each = toset(nonsensitive([for db in local.postgres_init : db.user if db.password == "" && db.create_user]))
  length   = 20
  special  = false
}
