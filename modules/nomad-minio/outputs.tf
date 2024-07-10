output "minio_superuser_details" {
  value = {
    user     = var.minio_superuser_name
    password = local.minio_superuser_password
  }
  sensitive   = true
  description = "The details of the superuser for MinIO"
}
