locals {
  root_password = var.root_password == "" ? random_password.root_password[0].result : var.root_password
  masterkey     = var.masterkey == "" ? random_password.masterkey[0].result : var.masterkey
}

resource "random_password" "root_password" {
  count = var.root_password == "" ? 1 : 0
  # password has special characters requiement
  # error="ID=COMMA-ZDLwA Message=Errors.User.PasswordComplexityPolicy.HasSymbol"
  length = 16
}

resource "random_password" "masterkey" {
  count = var.masterkey == "" ? 1 : 0
  # https://zitadel.com/docs/self-hosting/manage/configure#masterkey
  # masterkey must be 32 bytes
  length  = 32
  special = false
}
