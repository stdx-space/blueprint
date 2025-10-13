output "job_name" {
  description = "Name of the Nomad job"
  value       = nomad_job.openfga.name
}

output "http_service_name" {
  description = "Consul/Nomad service name for HTTP API"
  value       = "openfga-http"
}

output "grpc_service_name" {
  description = "Consul/Nomad service name for gRPC API"
  value       = "openfga-grpc"
}

output "generated_preshared_keys" {
  description = "Generated preshared keys (if any)"
  value       = local.generate_keys ? [random_password.preshared_key[0].result] : []
  sensitive   = true
}
