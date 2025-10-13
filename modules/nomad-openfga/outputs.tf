output "generated_preshared_keys" {
  description = "Generated preshared keys (if any)"
  value       = local.generate_keys ? [random_password.preshared_key[0].result] : []
  sensitive   = true
}
