data "external" "env" {
  program = ["jq", "-n", "env"]
}

resource "cloudflare_workers_kv_namespace" "registry" {
  account_id = data.external.env.result["CLOUDFLARE_ACCOUNT_ID"]
  title      = "modules"
}
resource "cloudflare_workers_script" "registry" {
  account_id          = data.external.env.result["CLOUDFLARE_ACCOUNT_ID"]
  name                = "registry"
  content             = file("${path.module}/dist/index.js")
  module              = true
  compatibility_date  = "2024-11-06"
  compatibility_flags = ["nodejs_compat"]

  kv_namespace_binding {
    namespace_id = cloudflare_workers_kv_namespace.registry.id
    name         = "modules"
  }
  r2_bucket_binding {
    name        = "artifact"
    bucket_name = "artifact"
  }
}
