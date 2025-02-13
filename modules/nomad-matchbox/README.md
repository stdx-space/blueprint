# Terraform module for running Matchbox on Nomad

## Usage

```hcl
module "matchbox" {
  source             = "registry.narwhl.workers.dev/stack/matchbox/nomad"
  matchbox_version   = "latest"
  dnsmasq_version    = "v0.5.0-40-g494d4e0"
  dhcp_range         = ["192.168.100.5", "192.168.100.15"]
  grpc_tls_cert      = "..."
  grpc_tls_key       = "..."
  ca_cert_pem        = "..."
  flatcar_version    = "4152.2.0"
  talos_version      = "v1.9.3"
  talos_schematic_id = "..."
}
```

## Argument Reference

- `job_name`: `(string: "matchbox")` - The name of the Nomad job.

- `datacenter_name`: `(string: "dc1")` - The datacenter to deploy the job to.

- `namespace`: `(string: "default")` - The namespace to deploy the job to.

- `matchbox_version`: `(string: <required>)` - The version of Matchbox to deploy.

- `dnsmasq_version`: `(string: <required>)` - The version of Dnsmasq to deploy.

- `dhcp_range`: `([]string: <required>)` - The start and end of the DHCP range.

- `grpc_tls_cert`: `(string: <required>)` - The PEM-encoded gRPC TLS certificate.

- `grpc_tls_key`: `(string: <required>)` - The PEM-encoded gRPC TLS key.

- `ca_cert_pem`: `(string: <required>)` - The PEM-encoded gRPC TLS CA certificate.

- `flatcar_version`: `(string: <required>)` - The version of Flatcar Container Linux to deploy.

- `talos_version`: `(string: <required>)` - The version of Talos to deploy.

- `talos_schematic_id`: `(string: <required>)` - The Schematic ID for Talos.
