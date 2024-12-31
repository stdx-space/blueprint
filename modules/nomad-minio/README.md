# Terraform module for running MinIO on Nomad

## Usage

```hcl
module "nomad_minio" {
  source          = "registry.narwhl.workers.dev/stack/minio/nomad"
  datacenter_name = "dc1"
  minio_hostname  = "files.example.app"
}
```

### Configuration

`datacenter_name`: The name of the Nomad datacenter to use.

`minio_hostname`: The hostname of the MinIO server

`minio_superuser_name`: The name of the MinIO superuser

`minio_superuser_password`: The password of the MinIO superuser. If not set, a random password will be generated.
