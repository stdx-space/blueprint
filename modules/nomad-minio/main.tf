locals {
  nomad_var_template       = "{{ with nomadVar \"nomad/jobs/${var.job_name}\" }}{{ .%s }}{{ end }}"
  minio_superuser_password = var.minio_superuser_password == "" ? random_password.superuser_password[0].result : var.minio_superuser_password
}

resource "nomad_variable" "minio" {
  path = "nomad/jobs/${var.job_name}"
  items = {
    minio_superuser_password = local.minio_superuser_password
  }
}

resource "nomad_job" "minio" {
  jobspec = templatefile("${path.module}/templates/minio.nomad.hcl.tftpl", {
    job_name        = var.job_name
    datacenter_name = var.datacenter_name
    namespace       = var.namespace
    minio_hostname  = var.minio_hostname
    minio_user      = var.minio_superuser_name
    minio_password  = format(local.nomad_var_template, "minio_superuser_password")
    host_volume_configs = var.host_volume_config != null ? [
      {
        source    = var.host_volume_config.source
        read_only = var.host_volume_config.read_only
      }
    ] : []
    resources                      = var.resources
    consul_service_configs         = var.service_discovery_provider == "consul" ? [{}] : []
    consul_connect_service_configs = var.service_discovery_provider == "consul-connect" ? [{}] : []
    nomad_service_configs          = var.service_discovery_provider == "nomad" ? [{}] : []
    https_configs                  = var.enable_https ? [{}] : []
    traefik_entrypoint             = var.traefik_entrypoint
    initialize_buckets_playbook    = file("${path.module}/templates/initialize-buckets.yaml")
    initialize_buckets_vars = yamlencode({
      aws_access_key   = var.minio_superuser_name
      aws_secret_key   = format(local.nomad_var_template, "minio_superuser_password")
      aws_endpoint_url = "http://localhost:9000"
      s3_buckets       = var.create_buckets
    })
  })
  purge_on_destroy = var.purge_on_destroy
}
