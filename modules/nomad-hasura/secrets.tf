resource "random_password" "hasura_admin_secret" {
  count   = var.hasura_admin_secret == "" ? 1 : 0
  length  = 20
  special = false
}
