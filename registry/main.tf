data "external" "env" {
  program = ["jq", "-n", "env"]
}

resource "cloudflare_workers_kv_namespace" "registry" {
  account_id = data.external.env.result["CLOUDFLARE_ACCOUNT_ID"]
  title      = "modules"
}

resource "cloudflare_workers_script" "registry" {
  account_id          = data.external.env.result["CLOUDFLARE_ACCOUNT_ID"]
  script_name         = "registry"
  content             = file("${path.module}/dist/index.js")
  main_module         = "index.js"
  compatibility_date  = "2024-11-06"
  compatibility_flags = ["nodejs_compat"]

  bindings = [
    {
      type         = "kv_namespace"
      namespace_id = cloudflare_workers_kv_namespace.registry.id
      name         = "modules"
    },
    {
      type        = "r2_bucket"
      name        = "artifact"
      bucket_name = "artifact"
    }
  ]
}