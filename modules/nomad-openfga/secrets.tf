locals {
  # Generate random preshared keys if not provided and method is preshared
  generate_keys = var.authn_method == "preshared" && length(var.authn_preshared_keys) == 0

  # Use provided keys or generated keys
  preshared_keys = local.generate_keys ? [
    random_password.preshared_key[0].result
  ] : var.authn_preshared_keys
}

resource "random_password" "preshared_key" {
  count   = local.generate_keys ? 1 : 0
  length  = 32
  special = true
}
