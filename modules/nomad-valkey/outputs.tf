output "job_name" {
  description = "The name of the Valkey Nomad job"
  value       = nomad_job.valkey.name
}

output "dynamic_host_volume_id" {
  description = "The ID of the dynamic host volume (if created)"
  value       = var.dynamic_host_volume_config != null ? nomad_dynamic_host_volume.valkey_data[0].id : null
}

output "dynamic_host_volume_name" {
  description = "The name of the dynamic host volume (if created)"
  value       = var.dynamic_host_volume_config != null ? nomad_dynamic_host_volume.valkey_data[0].name : null
}
