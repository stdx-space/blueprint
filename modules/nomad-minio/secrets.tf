resource "random_password" "superuser_password" {
  count   = var.minio_superuser_password == "" ? 1 : 0
  length  = 20
  special = false
}
