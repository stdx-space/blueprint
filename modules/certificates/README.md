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

### Required

- `ca_private_key_pem`: `(string: <required>)`

- `ca_cert_pem`: `(string: <required>)`

- `bit_length`: `(number: <optional>)`

- `client`: `(object)`

- `server`: `(object)`

### Nested Schema for `client`

- `common_name`: `(string)`

- `ttl`: `(number)`

### Nested Schema for `server`

- `san_dns_names`: `([]string: )`

- `san_ip_addresses`: `([]string: )`

- `ttl`: `(number)`

### Outputs

- `servers`: `([]object)`

- `clients`: `([]object)`

### Nested Schema for `servers`

- `cert_pem` (String)

- `key_pem` (String)

### Nested Schema for `clients`

- `cert_pem` (String)

- `key_pem` (String)
