# Terraform module for running Spilo HA PostgreSQL on Nomad

## Usage

```terraform
module "nomad_postgres" {
  source = "github.com/narwhl/blueprint//modules/nomad-spilo"
  datacenter_name = "dc1"

}
```

## Service Discovery

This module only allows using `consul` for service discovery. As `nomad`
service discovery returns all services instead of only healthy services.

https://github.com/hashicorp/nomad/issues/23317#issuecomment-2189917446

This module relies on health checking to determine the leader of the
postgres cluster. Without health checking, it is not possible to
determine which node is writable.

All instances are registered as Consul `postgres-ro` service and the
leader is registered as `postgres-rw` service.
