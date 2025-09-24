locals {
  nomad_var_template      = "{{ with nomadVar `nomad/jobs/${var.job_name}` }}{{ .%s }}{{ end }}"
  nomad_upstream_template = "{{ env `NOMAD_UPSTREAM_ADDR_%s` }}"

  // Modified from https://github.com/grafana/docker-otel-lgtm/blob/main/docker/otelcol-config.yaml
  // With reference to https://opentelemetry.io/docs/collector/configuration/
  otel_collector_config = yamlencode({
    receivers = {
      otlp = {
        protocols = {
          grpc = {
            endpoint = "0.0.0.0:4317"
          }
          http = {
            endpoint = "0.0.0.0:4318"
          }
        }
      }
    }
    exporters = {
      "otlphttp/metrics" = {
        endpoint = format("http://%s/api/v1/otlp", format(local.nomad_upstream_template, var.service_name_prometheus))
        tls = {
          insecure = true
        }
      }
      "otlphttp/logs" = {
        endpoint = format("http://%s/otlp", format(local.nomad_upstream_template, var.service_name_loki))
        tls = {
          insecure = true
        }
      }
    }
    service = {
      pipelines = {
        metrics = {
          receivers = ["otlp"]
          exporters = ["otlphttp/metrics"]
        }
        logs = {
          receivers = ["otlp"]
          exporters = ["otlphttp/logs"]
        }
      }
    }
  })
  grafana_config = yamlencode({
    apiVersion = 1
    datasources = [
      {
        name   = "Loki"
        type   = "loki"
        access = "proxy"
        url    = format("http://%s", format(local.nomad_upstream_template, var.service_name_loki))
      },
      {
        name      = "Prometheus"
        type      = "prometheus"
        access    = "proxy"
        url       = format("http://%s", format(local.nomad_upstream_template, var.service_name_prometheus))
        isDefault = true
      }
    ]
  })
  loki_config = yamlencode({
    auth_enabled = false
    server = {
      http_listen_port = 3100
    }
    ingester = {
      wal = {
        dir = "/loki/wal"
      }
      lifecycler = {
        address = "127.0.0.1"
        ring = {
          kvstore = {
            store = "inmemory"
          }
          replication_factor = 1 // Sensible for small setups; increase for HA
        }
      }
      chunk_idle_period   = "1h"
      max_chunk_age       = "1h"
      chunk_retain_period = "30s"
    }
    schema_config = {
      configs = [
        {
          from         = "2020-10-24"
          store        = "tsdb"
          object_store = "filesystem"
          schema       = "v13"
          index = {
            prefix = "index_"
            period = "24h"
          }
        }
      ]
    }
    storage_config = {
      tsdb_shipper = {
        active_index_directory = "/loki/tsdb-index"
        cache_location         = "/loki/tsdb-cache"
        cache_ttl              = "24h"
      }
      filesystem = {
        directory = "/loki/chunks"
      }
    }
    compactor = {
      working_directory = "/loki/compactor"
    }
    limits_config = {
      reject_old_samples : true
      reject_old_samples_max_age : "168h"
    }
    table_manager = {
      retention_deletes_enabled = false
      retention_period          = "0s"
    }
  })
  prometheus_config = yamlencode({
    global = {
      scrape_interval     = "15s"
      evaluation_interval = "15s"
    }
    scrape_configs = [
      {
        job_name = "prometheus"
        static_configs = [
          {
            targets = ["localhost:9090"]
          }
        ]
      },
      {
        job_name     = "nomad"
        metrics_path = "/v1/metrics"
        params = {
          format = ["prometheus"]
        }
        static_configs = [
          {
            targets = [format(local.nomad_upstream_template, "nomad")]
          }
        ]
      }
    ]
  })
}

resource "random_password" "grafana_admin" {
  length  = 16
  special = true
}

resource "nomad_variable" "grafana_loki_prometheus" {
  path      = "nomad/jobs/${var.job_name}"
  namespace = var.namespace
  items = {
    grafana_admin_password = coalesce(var.grafana_admin_password, random_password.grafana_admin.result)
  }
}

resource "nomad_job" "grafana_loki_prometheus" {
  jobspec = templatefile("${path.module}/templates/jobspec.nomad.hcl.tftpl", {
    job_name                = var.job_name
    datacenter_name         = var.datacenter_name
    namespace               = var.namespace
    otel_version            = var.otel_version
    otel_collector_config   = local.otel_collector_config
    grafana_version         = var.grafana_version
    grafana_config          = local.grafana_config
    grafana_admin_password  = format(local.nomad_var_template, "grafana_admin_password")
    grafana_fqdn            = var.grafana_fqdn
    traefik_entrypoints     = var.traefik_entrypoints
    loki_version            = var.loki_version
    loki_config             = local.loki_config
    prometheus_version      = var.prometheus_version
    prometheus_config       = local.prometheus_config
    resources               = var.resources
    service_name_otel       = var.service_name_otel
    service_name_grafana    = var.service_name_grafana
    service_name_loki       = var.service_name_loki
    service_name_prometheus = var.service_name_prometheus
  })
  purge_on_destroy = var.purge_on_destroy
  depends_on = [
    nomad_variable.grafana_loki_prometheus,
    nomad_dynamic_host_volume.prometheus,
    nomad_dynamic_host_volume.loki,
  ]
}

resource "nomad_dynamic_host_volume" "prometheus" {
  name      = "prometheus"
  plugin_id = "mkdir"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_dynamic_host_volume" "loki" {
  name      = "loki"
  plugin_id = "mkdir"

  parameters = {
    mode = "0755"
    uid  = 10001
    gid  = 10001
  }

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}
