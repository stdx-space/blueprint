# Terraform module for running Grafana, Loki, and Prometheus on Nomad

This module deploys a monitoring stack on Nomad, consisting of Grafana for visualization, Loki for log aggregation, and Prometheus for metrics collection.

## Usage

Minimal configuration for running the module:

```hcl
module "monitoring" {
  source          = "registry.narwhl.workers.dev/stack/grafana-loki-prometheus/nomad"
  datacenter_name = "dc1"
}
```

## Argument Reference

- `datacenter_name`: `(string: <required>)` - The name of the Nomad datacenter to run the job in.
- `namespace`: `(string: "default")` - The namespace to run the job in.
- `job_name`: `(string: "hasura")` - The name of the Nomad job.
- `purge_on_destroy`: `(bool: false)` - If set to true, the job will be purged from Nomad when destroyed.
- `grafana_version`: `(string: "latest")` - The version of Grafana to deploy.
- `loki_version`: `(string: "latest")` - The version of Loki to deploy.
- `prometheus_version`: `(string: "latest")` - The version of Prometheus to deploy.
- `resources`: `(map(object({ cpu = optional(number, 1000), memory = optional(number, 2048) }))):` - A map of resources to allocate to each component of the stack. The keys can be `grafana`, `loki`, and `prometheus`.

## Outputs

This module has no outputs.
