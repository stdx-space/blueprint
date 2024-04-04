resource "nomad_job" "nfs-controller" {
  purge_on_destroy = true
  jobspec = templatefile(
    "${path.module}/templates/controller.nomad.hcl.tftpl",
    {
      datacenter_name = var.datacenter_name
      plugin_id       = var.plugin_id
      version         = var.nfs_csi_driver_version
    }
  )
}

resource "nomad_job" "nfs-node" {
  purge_on_destroy = true
  jobspec = templatefile(
    "${path.module}/templates/node.nomad.hcl.tftpl",
    {
      datacenter_name = var.datacenter_name
      plugin_id       = var.plugin_id
      version         = var.nfs_csi_driver_version
    }
  )
}

resource "nomad_csi_volume_registration" "nfs" {
  for_each              = local.volumes
  volume_id             = each.value.directory // unique identifier for the volume
  name                  = each.key             // display name for the volume
  deregister_on_destroy = true
  plugin_id             = var.plugin_id
  external_id = format(
    "%s#%s#%s",
    var.nfs_server_address,
    each.value.directory,
    var.nfs_share_name
  )
  depends_on = [
    nomad_job.nfs-controller,
    nomad_job.nfs-node
  ]
  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }
  context = {
    server           = var.nfs_server_address
    share            = var.nfs_share_name
    subDir           = each.value.directory
    mountPermissions = each.value.permissions
  }
  mount_options {
    fs_type     = "nfs"
    mount_flags = ["timeo=30", "intr", "vers=3", "_netdev", "nolock"]
  }
}
