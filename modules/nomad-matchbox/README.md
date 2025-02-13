# Terraform module for running Matchbox on Nomad

## Usage

```hcl

```

## Argument Reference

- `job_name`: `(string: "matchbox")` - The name of the Nomad job.

- `datacenter_name`: `(string: "dc1")` - The datacenter to deploy the job to.

- `namespace`: `(string: "default")` - The namespace to deploy the job to.

- `matchbox_version`: `(string: <required>)` - The version of Matchbox to deploy.

- `dnsmasq_version`: `(string: <required>)` - The version of Dnsmasq to deploy.

- `dhcp_range_start`: `(string: <required>)` - The start of the DHCP range.

- `dhcp_range_end`: `(string: <required>)` - The end of the DHCP range.

- `grpc_tls_cert`: `(string: <required>)` - The PEM-encoded gRPC TLS certificate.

- `grpc_tls_key`: `(string: <required>)` - The PEM-encoded gRPC TLS key.

- `ca_cert_pem`: `(string: <required>)` - The PEM-encoded gRPC TLS CA certificate.

- `flatcar_version`: `(string: <required>)` - The version of Flatcar Container Linux to deploy.

- `talos_version`: `(string: <required>)` - The version of Talos to deploy.

- `talos_schematic_id`: `(string: <required>)` - The Schematic ID for Talos.
