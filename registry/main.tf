resource "cloudflare_worker_script" "registry" {
  account_id = data.external.env.result["CLOUDFLARE_ACCOUNT_ID"]
  name       = "registry"
  content    = file("${path.module}/dist/index.js")
  module     = true

  r2_bucket_binding {
    name        = "artifact"
    bucket_name = "artifact"
  }
}