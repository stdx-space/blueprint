output "hasura_admin_secret" {
  value     = local.hasura_admin_secret
  sensitive = true
}
