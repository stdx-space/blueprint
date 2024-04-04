output "ip_address" {
  value = flatten(proxmox_virtual_environment_vm.this.ipv4_addresses)[1]
}
