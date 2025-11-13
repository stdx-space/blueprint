output "credentials" {
  value = {
    access_key_id     = var.minio_superuser_name
    secret_access_key = local.minio_superuser_password
  }
  sensitive   = true
  description = "The details of the superuser for MinIO"
}

