# Nomad OpenFGA Module

This Terraform module deploys [OpenFGA](https://openfga.dev/) on HashiCorp Nomad. OpenFGA is a high-performance authorization/permission engine built for developers and inspired by Google Zanzibar.

## Features

- Configurable datastore backend (PostgreSQL, MySQL, SQLite)
- Multiple authentication methods (preshared keys, OIDC, none)
- TLS support for HTTP and gRPC
- Production-ready defaults
- Automatic database migration via Nomad prestart hook
- Internal service registration (no external ingress)
- Metrics and tracing support

## Usage

### Basic Usage with PostgreSQL

```hcl
module "openfga" {
  source = "registry.narwhl.workers.dev/stack/openfga/nomad"

  datacenter_name = "dc1"
  datastore = {
    postgres = {
      password = "secure-password"
    }
  }
}
```

### With Pre-shared Key Authentication

```hcl
module "openfga" {
  source = "registry.narwhl.workers.dev/stack/openfga/nomad"

  datacenter_name = "dc1"
  datastore = {
    postgres = {
      password = "secure-password"
    }
  }
  authn_method         = "preshared"
  authn_preshared_keys = ["key1", "key2"]
}
```

If `authn_preshared_keys` is empty, a random key will be generated automatically.

### With OIDC Authentication

```hcl
module "openfga" {
  source = "registry.narwhl.workers.dev/stack/openfga/nomad"

  datacenter_name = "dc1"
  datastore = {
    postgres = {
      password = "secure-password"
    }
  }
  authn_method        = "oidc"
  authn_oidc_issuer   = "https://auth.example.com"
  authn_oidc_audience = "openfga-api"
}
```

### With Custom Datastore URI

```hcl
module "openfga" {
  source = "registry.narwhl.workers.dev/stack/openfga/nomad"

  datacenter_name = "dc1"
  datastore = {
    uri = "postgres://user:pass@host:5432/dbname?sslmode=require"
  }
}
```

### With Custom PostgreSQL Connection

```hcl
module "openfga" {
  source = "registry.narwhl.workers.dev/stack/openfga/nomad"

  datacenter_name = "dc1"
  datastore = {
    postgres = {
      host     = "custom-postgres.example.com"
      port     = "5432"
      database = "openfga_prod"
      username = "openfga_user"
      password = "secure-password"
      ssl_mode = "require"
    }
  }
}
```

### With TLS Enabled

```hcl
module "openfga" {
  source = "registry.narwhl.workers.dev/stack/openfga/nomad"

  datacenter_name = "dc1"
  datastore = {
    postgres = {
      password = "secure-password"
    }
  }

  http_tls_enabled = true
  http_tls_cert    = "/path/to/cert.pem"
  http_tls_key     = "/path/to/key.pem"

  grpc_tls_enabled = true
  grpc_tls_cert    = "/path/to/grpc-cert.pem"
  grpc_tls_key     = "/path/to/grpc-key.pem"
}
```

### With Playground Enabled (Development Only)

```hcl
module "openfga" {
  source = "registry.narwhl.workers.dev/stack/openfga/nomad"

  datacenter_name = "dc1"
  datastore = {
    postgres = {
      password = "secure-password"
    }
  }
  playground_enabled = true
}
```

> **Warning:** Disable the playground in production environments.

## Variables

| Name              | Type   | Default     | Description                       |
| ----------------- | ------ | ----------- | --------------------------------- |
| `datacenter_name` | string | -           | Name of the datacenter (required) |
| `namespace`       | string | `"default"` | Nomad namespace                   |
| `job_name`        | string | `"openfga"` | Nomad job name                    |
| `openfga_version` | string | `"latest"`  | OpenFGA Docker image version      |

### Datastore Configuration

| Name                          | Type   | Default                  | Description                                      |
| ----------------------------- | ------ | ------------------------ | ------------------------------------------------ |
| `datastore`                   | object | See below                | Datastore configuration object (sensitive)       |
| `datastore.engine`            | string | `"postgres"`             | Datastore engine (postgres, mysql, or sqlite)    |
| `datastore.uri`               | string | `""`                     | Full datastore URI (overrides individual params) |
| `datastore.postgres`          | object | `{}`                     | PostgreSQL connection parameters                 |
| `datastore.postgres.host`     | string | Consul service discovery | PostgreSQL host                                  |
| `datastore.postgres.port`     | string | Consul service discovery | PostgreSQL port                                  |
| `datastore.postgres.database` | string | `"openfga"`              | PostgreSQL database name                         |
| `datastore.postgres.username` | string | `"openfga"`              | PostgreSQL username                              |
| `datastore.postgres.password` | string | `""`                     | PostgreSQL password                              |
| `datastore.postgres.ssl_mode` | string | `"disable"`              | PostgreSQL SSL mode                              |

### Authentication Configuration

| Name                          | Type         | Default                | Description                                      |
| ----------------------------- | ------------ | ---------------------- | ------------------------------------------------ |
| `authn_method`                | string       | `"preshared"`          | Authentication method (none, preshared, or oidc) |
| `authn_preshared_keys`        | list(string) | `[]`                   | Pre-shared keys (auto-generated if empty)        |
| `authn_oidc_issuer`           | string       | `""`                   | OIDC issuer URL                                  |
| `authn_oidc_audience`         | string       | `""`                   | OIDC audience                                    |
| `authn_oidc_client_id_claims` | list(string) | `["azp", "client_id"]` | OIDC client ID claims                            |

### TLS Configuration

| Name               | Type   | Default | Description                  |
| ------------------ | ------ | ------- | ---------------------------- |
| `http_tls_enabled` | bool   | `false` | Enable TLS for HTTP server   |
| `http_tls_cert`    | string | `""`    | Path to HTTP TLS certificate |
| `http_tls_key`     | string | `""`    | Path to HTTP TLS key         |
| `grpc_tls_enabled` | bool   | `false` | Enable TLS for gRPC server   |
| `grpc_tls_cert`    | string | `""`    | Path to gRPC TLS certificate |
| `grpc_tls_key`     | string | `""`    | Path to gRPC TLS key         |

### Production Settings

| Name                        | Type   | Default  | Description                               |
| --------------------------- | ------ | -------- | ----------------------------------------- |
| `playground_enabled`        | bool   | `false`  | Enable playground (disable in production) |
| `log_format`                | string | `"json"` | Log format (text or json)                 |
| `log_level`                 | string | `"info"` | Log level (debug, info, warn, error)      |
| `metrics_enabled`           | bool   | `true`   | Enable metrics collection                 |
| `datastore_metrics_enabled` | bool   | `true`   | Enable datastore metrics                  |
| `trace_enabled`             | bool   | `false`  | Enable distributed tracing                |
| `trace_sample_ratio`        | number | `0.3`    | Trace sample ratio (0.0-1.0)              |

### Resource Configuration

| Name               | Type   | Default                 | Description               |
| ------------------ | ------ | ----------------------- | ------------------------- |
| `resources`        | object | `{cpu=500, memory=512}` | CPU and memory allocation |
| `purge_on_destroy` | bool   | `false`                 | Purge job on destroy      |

## Outputs

| Name                       | Description                                  |
| -------------------------- | -------------------------------------------- |
| `generated_preshared_keys` | Generated preshared keys (if any, sensitive) |

## Service Discovery

The module registers the following internal services:

- `openfga-http` - HTTP API on port 8080
- `openfga-grpc` - gRPC API on port 8081
- `openfga-playground` - Playground UI on port 3000 (if enabled)

Access these services using Consul service discovery from other Nomad jobs.

## Production Recommendations

For production deployments, follow these best practices:

1. **Disable the playground**: Set `playground_enabled = false`
2. **Enable authentication**: Use preshared keys or OIDC
3. **Enable TLS**: Configure HTTP and/or gRPC TLS
4. **Use JSON logging**: Set `log_format = "json"`
5. **Enable metrics**: Keep `metrics_enabled = true`
6. **Co-locate database**: Ensure PostgreSQL is in the same datacenter
7. **Configure tracing**: Enable with low sample ratio for observability

## Requirements

- HashiCorp Nomad 1.6+
- PostgreSQL, MySQL, or SQLite database
- Terraform 1.0+

## License

See the main repository license.
