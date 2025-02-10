# Terraform module for running MinIO on Nomad

## Usage

```hcl
module "nomad_minio" {
  source          = "registry.narwhl.workers.dev/stack/minio/nomad"
  datacenter_name = "dc1"
  minio_hostname  = "files.example.app"
}
```

## Argument Reference

`datacenter_name`: `(string: "dc1")` - The name of the Nomad datacenter to use.

`minio_hostname`: `(string: <optional>)` - The hostname of the MinIO server

`minio_superuser_name`: `(string: "minio")` - The name of the MinIO superuser

`minio_superuser_password`: `(string: <optional>)` - The password of the MinIO superuser. If not set, a random password will be generated.

## Outputs

`credentials`: `(object)`

### Nested Schema for `credentials`

- `access_key_id`: `(string)`

- `secret_access_key`: `(string)`