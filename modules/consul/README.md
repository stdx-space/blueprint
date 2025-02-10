# Terraform module for running Consul on Flatcar/ Debian

## Usage

Include output `manifest` in `substrates` of `debian` or `flatcar` module.

```terraform
module "consul" {
    source = "registry.narwhl.workers.dev/service/consul/systemd"
    datacenter_name = "dc1"
    role            = "server"
}

# Alternatively, you may use Flatcar module
module "debian" {
  source = "registry.narwhl.workers.dev/os/debian/cloudinit"
  name   = "debian-vm"
  substrates = [
    module.consul.manifest,
    ...
  ]
  ...
}
```

## Argument Reference

- `supplychain`: `(string: "https://artifact.narwhl.dev/upstream/current.json")` - Address pointing to upstream dependency JSON metadata file. This should leave as default unless package
versions need to be customized. Defaults to `https://artifact.narwhl.dev/upstream/current.json`.

- `data_dir`: `(string: "/opt/consul")` - The directory to store Consul data. Defaults to `/opt/consul`.

- `datacenter_name`: `(string: "dc1")` - The name of the Consul datacenter to use.

- `log_level`: `(string: "INFO")` - The log level to use. Defaults to `INFO`.

- `role`: `(string: "client")` - The role of the Consul node to run, can be `client` or `server`. Defaults to `client`.

- `consul_user`: `(string: "consul")` - User running Consul. For setting file permissions in config. Defaults to `consul`.

- `consul_group`: `(string: "consul")` - Group of user running Consul. For setting file permissions in config. Defaults to `consul`.

- `bootstrap_expect`: `(number: 1)` - Number of consul instance connection expected to form the cluster. Must be an odd integer.
Defaults to `1`.

- `retry_join`: `[]string` - Parameter value for DNS address, IP address or cloud auto-join configuration

- `gossip_key`: `(string: <optional>)` - The gossip encryption key. Gossip encryption is not enforced when leaving this empty.

- `connect`: `(bool: true)` - Enable Consul Connect

- `ui`: `(bool: true)` - Enable Consul UI

- `advertise_addr`: `(string: "{{ GetPrivateIP }}")` - Address to advertise for Consul agent

- `listen_addr`: `(string: "{{ GetPrivateIP }}")` - Address to bind the Consul agent to

- `resolve_consul_domains`: `(bool: false)` Whether to point DNS records for *.service.consul to the consul servers. Defaults to `false`

- `tls`: `(object)` The TLS certificate configuration. TLS is not enforced when leaving this empty.


### Outputs

- `manifest`: `(object)`
