locals {
  nomad_var_template = "{{ with nomadVar \"nomad/jobs/${var.job_name}\" }}{{ .%s }}{{ end }}"

  # Construct datastore URI if not provided
  default_datastore_uri = var.datastore.engine == "postgres" ? "postgres://${var.datastore.postgres.username}:${format(local.nomad_var_template, "postgres_password")}@${var.datastore.postgres.host}:${var.datastore.postgres.port}/${var.datastore.postgres.database}?sslmode=${var.datastore.postgres.ssl_mode}" : ""

  datastore_uri = var.datastore.uri != "" ? var.datastore.uri : local.default_datastore_uri

  # Format preshared keys as comma-separated string
  preshared_keys_string = join(",", local.preshared_keys)
}

resource "nomad_variable" "openfga" {
  path      = "nomad/jobs/${var.job_name}"
  namespace = var.namespace
  items = merge(
    var.datastore.postgres.password != "" ? {
      postgres_password = var.datastore.postgres.password
    } : {},
    var.authn_method == "preshared" ? {
      preshared_keys = local.preshared_keys_string
    } : {}
  )
}

resource "nomad_job" "openfga" {
  jobspec = templatefile("${path.module}/templates/openfga.nomad.hcl.tftpl", {
    job_name                     = var.job_name
    datacenter_name              = var.datacenter_name
    namespace                    = var.namespace
    openfga_version              = var.openfga_version
    datastore_engine             = var.datastore.engine
    datastore_uri                = local.datastore_uri
    authn_method                 = var.authn_method
    authn_preshared_keys         = var.authn_method == "preshared" ? format(local.nomad_var_template, "preshared_keys") : ""
    authn_oidc_issuer            = var.authn_oidc_issuer
    authn_oidc_audience          = var.authn_oidc_audience
    authn_oidc_client_id_claims  = join(",", var.authn_oidc_client_id_claims)
    http_tls_enabled             = var.http_tls_enabled
    http_tls_cert                = var.http_tls_cert
    http_tls_key                 = var.http_tls_key
    grpc_tls_enabled             = var.grpc_tls_enabled
    grpc_tls_cert                = var.grpc_tls_cert
    grpc_tls_key                 = var.grpc_tls_key
    playground_enabled           = var.playground_enabled
    log_format                   = var.log_format
    log_level                    = var.log_level
    metrics_enabled              = var.metrics_enabled
    datastore_metrics_enabled    = var.datastore_metrics_enabled
    trace_enabled                = var.trace_enabled
    trace_sample_ratio           = var.trace_sample_ratio
    resources                    = var.resources
  })
  purge_on_destroy = var.purge_on_destroy

  depends_on = [nomad_variable.openfga]
}
