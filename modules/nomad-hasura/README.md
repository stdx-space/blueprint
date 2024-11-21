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
