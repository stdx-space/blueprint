output "root_password" {
  value       = local.root_password
  description = "The password for the root user"
}

output "masterkey" {
  value       = local.masterkey
  description = "The master key for zitadel"
}
