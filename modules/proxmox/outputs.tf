output "ip_address" {
  value = flatten(proxmox_virtual_environment_vm.this.ipv4_addresses)[1]
}

output "interface_name" {
  value = [for name in proxmox_virtual_environment_vm.this.network_interface_names : name if startswith(name, "e")][0]
}
