# Terraform module for self hosting Ory Hydra and Kratos on Nomad

### Usage

```hcl
module "ory" {
  datacenter_name        = "dc1" # name of the datacenter in Nomad
  hydra_version          = ""
  kratos_version         = ""
  postgres_version       = ""
  application_name       = ""
  root_domain            = "domain.tld"
  hydra_subdomain        = "login"
  kratos_ui_subdomain    = ""
  kratos_admin_subdomain = ""
  smtp_connection_uri    = ""
}
```