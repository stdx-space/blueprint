data "external" "env" {
  program = ["jq", "-n", "env"]
}

resource "cloudflare_worker_script" "registry" {
  account_id          = data.external.env.result["CLOUDFLARE_ACCOUNT_ID"]
  name                = "registry"
  content             = file("${path.module}/dist/index.js")
  module              = true
  compatibility_date  = "2024-11-06"
  compatibility_flags = ["nodejs_compat"]

  r2_bucket_binding {
    name        = "artifact"
    bucket_name = "artifact"
  }
}