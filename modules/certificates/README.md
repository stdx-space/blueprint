# Terraform module for provisioning PKI

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

- `ca_private_key_pem` (String)

- `ca_cert_pem` (String)

### Optional

- `bit_length` (Number)

- `client` (Block List)

- `server` (Block List)

### Nested Schema for `client`

- `common_name` (String)

- `ttl` (Number)

### Nested Schema for `server`

Optional

- `san_dns_names` (List of String)

- `san_ip_addresses` (List of String)

- `ttl` (Number)

### Outputs

- `servers` (List of Object)

- `clients` (List of Object)

### Nested Schema for `servers`

- `cert_pem` (String)

- `key_pem` (String)

### Nested Schema for `clients`

- `cert_pem` (String)

- `key_pem` (String)
