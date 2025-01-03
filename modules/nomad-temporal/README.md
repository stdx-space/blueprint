# Terraform module for self hosting Temporal on Nomad

This module deploys Temporal on Nomad. It uses PostgreSQL as the underlying
database. Elasticsearch is disabled and PostgreSQL is used for the visibility
database.

## Example Configuration

```hcl
module "temporal" {
  source                       = "registry.narwhl.workers.dev/stack/temporal/nomad"
  datacenter_name              = local.datacenter_name
  postgres_host                = "{{ with service `postgres-rw` }}{{ with index . 0 }}{{ .Address }}{{ end }}{{ end }}"
  postgres_port                = "{{ with service `postgres-rw` }}{{ with index . 0 }}{{ .Port }}{{ end }}{{ end }}"
  postgres_username            = "temporal"
  postgres_database            = "temporal"
  postgres_visibility_database = "temporal_visibility"
  postgres_password            = "{{ with nomadVar `nomad/jobs/postgres` }}{{ .temporal_password }}{{ end }}"
  temporal_version             = "1.26.2"
  temporal_ui_version          = "2.31.2"
}
```
