# Terraform module for self hosting Hasura on Nomad

## Usage

```hcl
module "hasura" {
  source              = "github.com/narwhl/blueprint//modules/nomad-hasura"
  datacenter_name     = "dc1"                        # Nomad datacenter name
  hasura_version      = "v2.42.0"                    # Hasura version
  hasura_admin_secret = "<your-hasura-admin-secret>" # Hasura admin secret
  db_address          = "10.0.0.1:5432"              # Postgres address
  db_user             = "postgres"                   # Postgres user
  db_password         = "<your-db-password>"         # Postgres password
  purge_on_destroy    = true                         # Purge Typesense job on destroy
}
```

## Argument Reference

- `datacenter_name`: `(string: <required>)` - The name of the Nomad datacenter to use.

- `namespace`: `(string: <optional>)` - The namespace to run the job in. Defaults to `default`.

- `job_name`: `(string: <optional>)` - The name of the job. Defaults to `hasura`.

- `hasura_version`: `(string: <optional>)` - The version of Hasura to run. Defaults to `latest`.

- `hasura_admin_secret`: `(string: <required>)` - The admin secret for Hasura.

- `db_address`: `(string: <required>)` - The address of the Postgres database.

- `db_username`: `(string: <required>)` - The username of the Postgres database.

- `db_password`: `(string: <required>)` - The password of the Postgres database.

- `resources`: `(object: <optional>)` - The resources to allocate to the job.

- `purge_on_destroy`: `(bool: <optional>)` - Whether to purge the job on destroy. Defaults to `false`.

## Outputs

- `hasura_admin_secret`: `(string)` - The admin secret for Hasura.
