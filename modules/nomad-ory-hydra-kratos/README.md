# Terraform module for self hosting Ory Hydra and Kratos on Nomad

### Usage

```hcl
module "ory" {
  source                 = "registry.narwhl.workers.dev/stack/idp/nomad"
  datacenter_name        = "dc1" # name of the datacenter in Nomad
  database_user          = "ory" # optional field, defaults to "ory", need to configure externally since db is not hosted from within this module
  database_password      = "my_secret_password" # required field, a single user will manages both hydra and kratos simultaneously
  database_addr          = "{ip_or_hostname}:{port}" # required field
  hydra_db_name          = "hydra" # optional field, defaults to "hydra"
  kratos_db_name         = "kratos" # optional field, defaults to "kratos"
  hydra_version          = "" # required field, should obtain this from oci image tag from registry
  kratos_version         = "" # required field, should obtain this from oci image tag from registry
  application_name       = "Acme Signle Sign-on" # required field
  root_domain            = "domain.tld" # required field, for composing subdomains that both hydra and kratos uses for its services
  hydra_subdomain        = "auth" # required field, for oauth server
  kratos_ui_subdomain    = "login" # required field, for idp login page, instance runs externally
  kratos_admin_subdomain = "accounts" # required field, for idp admin api
  smtp_connection_uri    = "smtp://{user:password}@{host:port}" # required field, http config for mail gateway tbd
}
```
