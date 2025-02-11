# Terraform module for provisioning certificates signed by supplied CA

### Usage

```hcl
module "certificates" {
  source             = "registry.narwhl.workers.dev/security/certificates/tls"
  ca_private_key_pem = ""
  ca_cert_pem        = ""
  client = [
    {
      common_name = "Client 1"
    }
  ]
  server = [
    {
      san_dns_names = ["server.global.nomad"]
      san_ip_addresses = ["127.0.0.1"]
    }
  ]
}
```

## Argument Reference

- `ca_private_key_pem`: `(string: <required>)` - PEM-encoded CA certificate

- `ca_cert_pem`: `(string: <required>)` - PEM-encoded CA private key

- `bit_length`: `(number: <optional>)` - Bit length of the generated certificate, defaults to 2048

- `client`: `([]object: <required>)` - List of client certificates

- `server`: `([]object: <required>)` - List of server certificates


### Nested Schema for `client`

- `common_name`: `(string: <required>)` - Common name of the client certificate

- `ttl`: `(number: <optional>)` - Time to live of the certificate, defaults to 6574 hours (9 months)

### Nested Schema for `server`

- `san_dns_names`: `([]string: <optional>)` - List of DNS names to include in the certificate

- `san_ip_addresses`: `([]string: <optional>)` - List of IP addresses to include in the certificate

- `ttl`: `(number: <optional>)` - Time to live of the certificate, defaults to 13149 hours (18 months)


### Outputs

- `servers`: `([]object)` - List of signed server certificates

- `clients`: `([]object)` - List of signed client certificates


### Nested Schema for `servers`

- `cert_pem`: `(string)` - PEM-encoded server certificate

- `key_pem`: `(string)` - PEM-encoded server private key

### Nested Schema for `clients`

- `cert_pem`: `(string)` - PEM-encoded client certificate

- `key_pem`: `(string)` - PEM-encoded client private key
