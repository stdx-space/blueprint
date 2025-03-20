locals {
  nomad_var_template = "{{ with nomadVar \"nomad/jobs/${var.job_name}\" }}{{ .%s }}{{ end }}"
  artifacts = {
    "https://www.flatcar.org/security/image-signing-key" = {
      files = [
        "Flatcar_Image_Signing_Key.asc"
      ]
      mount_path = "/var/lib/matchbox/assets/flatcar/${var.flatcar_version}"
    }
    "https://stable.release.flatcar-linux.net/amd64-usr/${var.flatcar_version}" = {
      files = [
        "flatcar_production_image.bin.bz2",
        "flatcar_production_image.bin.bz2.sig",
        "flatcar_production_pxe_image.cpio.gz",
        "flatcar_production_pxe_image.cpio.gz.sig",
        "flatcar_production_pxe.vmlinuz",
        "flatcar_production_pxe.vmlinuz.sig",
        "version.txt"
      ]
      mount_path = "/var/lib/matchbox/assets/flatcar/${var.flatcar_version}"
    }
    "https://factory.talos.dev/image/${talos_schematic_id}/${talos_version}" = {
      files = [
        "kernel-amd64",
        "initramfs.xz"
      ]
      mount_path = "/var/lib/matchbox/assets/talos/${var.talos_version}"
    }
  }
}

resource "nomad_variable" "matchbox" {
  path      = "nomad/jobs/${var.job_name}"
  namespace = var.namespace
  items = {
    grpc_tls_cert = var.grpc_tls_cert
    grpc_tls_key  = var.grpc_tls_key
    ca_cert_pem   = var.ca_cert_pem
  }
}

resource "nomad_job" "matchbox" {
  jobspec = templatefile("${path.module}/matchbox.nomad.hcl", {
    job_name           = var.job_name
    datacenter_name    = var.datacenter_name
    namespace          = var.namespace
    dnsmasq_version    = var.dnsmasq_version
    dhcp_range_start   = var.dhcp_range[0]
    dhcp_range_end     = var.dhcp_range[1]
    matchbox_version   = var.matchbox_version
    matchbox_ipxe_url  = "${var.matchbox_url}/boot.ipxe"
    flatcar_version    = var.flatcar_version
    talos_version      = var.talos_version
    talos_schematic_id = var.talos_schematic_id
    server_cert_pem    = format(local.nomad_var_template, "grpc_tls_cert")
    server_key_pem     = format(local.nomad_var_template, "grpc_tls_key")
    root_ca_cert_pem   = format(local.nomad_var_template, "ca_cert_pem")
    artifacts = join("\n", [
      for url in flatten([
        for prefix, value in local.artifacts : [
          for file in value.files : "${prefix}/${file}"
        ]
      ]) : <<-EOT
      artifact {
        source = "${url}"
        options {
          archive = false
        }
      }
      EOT
    ])
    mounts = join("\n", [
      for config in flatten([
        for prefix, value in local.artifacts : [
          for file in value.files : {
            source = "local/${file}"
            target = "${value.mount_path}/${file}"
          }
        ]
      ]) : <<-EOT
      mount {
        type   = "bind"
        source = "${config.source}"
        target = "${config.target}"
      }
      EOT
    ])
  })
  purge_on_destroy = true
}
