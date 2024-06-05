data "ignition_user" "operator" {
  name                = var.username
  ssh_authorized_keys = local.ssh_authorized_keys
}

data "ignition_user" "external" {
  for_each = local.users
  name     = each.key
  system   = true
  home_dir = each.value.home_dir
  uid      = each.value.uid
}

data "ignition_kernel_arguments" "disable_autologin" {
  shouldnotexist = ["flatcar.autologin"]
}

data "ignition_directory" "substrates" {
  for_each = {
    for directory in flatten(var.substrates.*.directories) : directory.path => {
      mode = local.permissions[directory.mode]
      uid  = lookup(local.users, directory.owner, { uid = 0 }).uid
      gid  = lookup(local.users, directory.group, { uid = 0 }).uid
    }
  }
  path = each.key
  mode = each.value.mode
  uid  = each.value.uid
  gid  = each.value.gid
}

data "ignition_file" "files" {
  for_each = local.files_contain_sensitive_data ? nonsensitive({
    for file in local.files : file.path => file if file.enabled == true && strcontains(file.tags, lookup(file, "tags", "ignition"))
    }) : {
    for file in local.files : file.path => file if file.enabled == true && strcontains(file.tags, lookup(file, "tags", "ignition"))
  }

  path      = each.key
  overwrite = true
  mode      = local.permissions[each.value.mode]
  uid       = lookup(local.users, each.value.owner, { uid = 0 }).uid
  gid       = lookup(local.users, each.value.group, { uid = 0 }).uid
  dynamic "content" {
    for_each = startswith(each.value.content, "https://") ? {} : { "${each.key}" = each.value }
    content {
      content = content.value.content
    }
  }

  dynamic "source" {
    for_each = startswith(each.value.content, "https://") ? { "${each.key}" = each.value } : {}
    content {
      source = source.value.content
    }
  }
}

data "ignition_disk" "disks" {
  for_each   = local.disks
  device     = each.key
  wipe_table = true
  partition {
    label = each.value
  }
}

data "ignition_filesystem" "fs" {
  for_each        = local.disks
  device          = each.key
  format          = "ext4"
  label           = each.value
  wipe_filesystem = true
}

data "ignition_systemd_unit" "services" {
  for_each = {
    for unit in local.systemd_units : unit.name => unit
  }
  enabled = true
  name    = each.key
  content = each.value.content

  dynamic "dropin" {
    for_each = try(each.value.dropins, {})
    content {
      name    = dropin.key
      content = dropin.value
    }
  }
}

data "ignition_systemd_unit" "disable_ssh" {
  name    = "sshd.service"
  enabled = false
}

data "ignition_systemd_unit" "disable_ssh_socket" {
  name = "sshd.socket"
  mask = true
}

data "ignition_config" "config" {
  dynamic "tls_ca" {
    for_each = {
      for index, cert in local.ca_certs : index => cert
    }
    content {
      source = tls_ca.value.source
    }
  }
  kernel_arguments = var.autologin ? "" : data.ignition_kernel_arguments.disable_autologin.rendered
  disks = [
    for disk, spec in data.ignition_disk.disks : spec.rendered
  ]
  filesystems = [
    for disk, fs in data.ignition_filesystem.fs : fs.rendered
  ]
  files = [
    for path, file in data.ignition_file.files : file.rendered
  ]
  systemd = concat([
    for name, unit in data.ignition_systemd_unit.services : unit.rendered
    ], var.disable_ssh ? [
    data.ignition_systemd_unit.disable_ssh.rendered,
    data.ignition_systemd_unit.disable_ssh_socket.rendered,
  ] : [])
  users = concat([for key, value in data.ignition_user.external : value.rendered], [data.ignition_user.operator.rendered], )
}
