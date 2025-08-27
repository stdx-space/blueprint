output "ip_address" {
  value = tolist([
    for ip in flatten(proxmox_virtual_environment_vm.this.ipv4_addresses) :
    ip if !(
      startswith(ip, "169.254") ||
      startswith(ip, "127.0.0")
    )
  ])[0]
}

output "interface_name" {
  value = [for name in proxmox_virtual_environment_vm.this.network_interface_names : name if startswith(name, "e")][0]
}
