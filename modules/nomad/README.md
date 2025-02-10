# Terraform module for running Nomad on Flatcar/ Debian

## Usage

Include output `manifest` in `substrates` of `debian` or `flatcar` module.

```terraform
module "nomad" {
    source = "registry.narwhl.workers.dev/service/nomad/systemd"
    datacenter_name = "dc1"
    role            = "server"
}

# Alternatively, you may use Flatcar module
module "debian" {
  source = "registry.narwhl.workers.dev/os/debian/cloudinit"
  name   = "debian-vm"
  substrates = [
    module.nomad.manifest,
    ...
  ]
  ...
}
```

## Argument Reference

- `supplychain`: `(string: "https://artifact.narwhl.dev/upstream/current.json")` Address pointing to upstream dependency JSON metadata file. This should leave as default unless package
versions need to be customized.

- `data_dir`: `(string: "/opt/consul")` The directory to store Nomad data. Defaults to `/opt/nomad`.

- `datacenter_name`: `(string: "dc1")` The name of the Nomad datacenter to use.

- `log_level`: `(string: "INFO")` The log level to use. Defaults to `INFO`.

- `role`: `(string: "client")` The role of the Nomad node to run, can be `client` or `server`. Defaults to `server`.

- `bootstrap_expect`: `(number: 1)` Number of nomad instance connection expected to form the cluster. Must be an odd integer.

- `gossip_key`: `(string: <optional>)` The gossip encryption key. Gossip encryption is not enforced when leaving this empty.

- `tls`: `(object: <optional>)` The TLS certificate configuration. TLS is not enforced when leaving this empty.

- `host_volume`: `([]string: <optional>)` A map of host volume configurations. The key is the host volume name and the value is an object with
the `path` and `read_only` fields. The `path` field is the path on the host where the volume is mounted and the
  - `read_only` field is a boolean indicating whether the volume is read-only.
