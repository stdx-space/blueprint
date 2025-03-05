job "${job_name}" {
  datacenters = ["${datacenter_name}"]
  type        = "service"
  namespace   = "${namespace}"

  group "matchbox" {

    network {
      mode = "host"
      port "http" {
        to     = 8080
        static = 8080
      }
      port "rpc" {
        to     = 8081
        static = 8081
      }
      port "dhcp" {
        static = 67
        to     = 67
      }
      port "dns" {
        static = 53
        to     = 53
      }
      port "tftp" {
        static = 69
        to     = 69
      }
    }

    task "dnsmasq" {

      driver = "docker"

      config {
        image    = "quay.io/poseidon/dnsmasq:${dnsmasq_version}"
        ports    = ["dhcp", "tftp", "dns"]

        mount {
          type   = "bind"
          source = "local/dnsmasq.conf"
          target = "/etc/dnsmasq.conf"
        }

        network_mode = "host"
        cap_add      = ["net_admin", "net_bind_service", "chown"]
        privileged   = true
      }

      template {
        data = <<-EOF
          keep-in-foreground
          dhcp-range=${dhcp_range_start},${dhcp_range_end},30m
          enable-tftp
          tftp-root=/var/lib/tftpboot

          # Legacy PXE
          dhcp-match=set:bios,option:client-arch,0
          dhcp-boot=tag:bios,undionly.kpxe

          # UEFI
          dhcp-match=set:efi32,option:client-arch,6
          dhcp-boot=tag:efi32,ipxe.efi
          dhcp-match=set:efibc,option:client-arch,7
          dhcp-boot=tag:efibc,ipxe.efi
          dhcp-match=set:efi64,option:client-arch,9
          dhcp-boot=tag:efi64,ipxe.efi

          # iPXE - chainload to matchbox ipxe boot script
          dhcp-userclass=set:ipxe,iPXE
          dhcp-boot=tag:ipxe,${matchbox_ipxe_url}

          log-queries
          log-dhcp
        EOF
        destination = "local/dnsmasq.conf"
        change_mode = "restart"
      }
    }

    task "matchbox" {

      driver = "docker"
      config {
        image    = "quay.io/poseidon/matchbox:${matchbox_version}"
        ports    = ["http", "rpc"]
        args = [
          "-address=0.0.0.0:8080",
          "-rpc-address=0.0.0.0:8081",
          "-log-level=debug",
        ]

        mount {
          type   = "bind"
          source = "local/Flatcar_Image_Signing_Key.asc"
          target = "/var/lib/matchbox/assets/flatcar/${flatcar_version}/Flatcar_Image_Signing_Key.asc"
        }

        mount {
          type   = "bind"
          source = "local/flatcar_production_image.bin.bz2"
          target = "/var/lib/matchbox/assets/flatcar/${flatcar_version}/flatcar_production_image.bin.bz2"
        }

        mount {
          type   = "bind"
          source = "local/flatcar_production_image.bin.bz2.sig"
          target = "/var/lib/matchbox/assets/flatcar/${flatcar_version}/flatcar_production_image.bin.bz2.sig"
        }

        mount {
          type   = "bind"
          source = "local/flatcar_production_pxe_image.cpio.gz"
          target = "/var/lib/matchbox/assets/flatcar/${flatcar_version}/flatcar_production_pxe_image.cpio.gz"
        }

        mount {
          type   = "bind"
          source = "local/flatcar_production_pxe_image.cpio.gz.sig"
          target = "/var/lib/matchbox/assets/flatcar/${flatcar_version}/flatcar_production_pxe_image.cpio.gz.sig"
        }

        mount {
          type   = "bind"
          source = "local/flatcar_production_pxe.vmlinuz"
          target = "/var/lib/matchbox/assets/flatcar/${flatcar_version}/flatcar_production_pxe.vmlinuz"
        }

        mount {
          type   = "bind"
          source = "local/flatcar_production_pxe.vmlinuz.sig"
          target = "/var/lib/matchbox/assets/flatcar/${flatcar_version}/flatcar_production_pxe.vmlinuz.sig"
        }

        mount {
          type   = "bind"
          source = "local/version.txt"
          target = "/var/lib/matchbox/assets/flatcar/${flatcar_version}/version.txt"
        }

        mount {
          type   = "bind"
          source = "local/kernel-amd64"
          target = "/var/lib/matchbox/assets/talos/${talos_version}/vmlinuz"
        }

        mount {
          type = "bind"
          source = "local/initramfs-amd64.xz"
          target = "/var/lib/matchbox/assets/talos/${talos_version}/initramfs.xz"
        }

        mount {
          type   = "bind"
          source = "local/server.crt"
          target = "/etc/matchbox/server.crt"
        }

        mount {
          type   = "bind"
          source = "local/server.key"
          target = "/etc/matchbox/server.key"
        }

        mount {
          type   = "bind"
          source = "local/ca.crt"
          target = "/etc/matchbox/ca.crt"
        }
      }

      template {
        data = <<-EOF
${server_cert_pem}
        EOF
        destination = "local/server.crt"
        change_mode = "restart"
      }

      template {
        data = <<-EOF
${server_key_pem}
        EOF
        destination = "local/server.key"
        change_mode = "restart"
      }

      template {
        data = <<-EOF
${root_ca_cert_pem}
        EOF
        destination = "local/ca.crt"
        change_mode = "restart"
      }

      artifact {
        source = "https://www.flatcar.org/security/image-signing-key/Flatcar_Image_Signing_Key.asc"
      }

      artifact {
        source = "https://stable.release.flatcar-linux.net/amd64-usr/${flatcar_version}/flatcar_production_image.bin.bz2"
        options {
          archive = false
        }
      }

      artifact {
        source = "https://stable.release.flatcar-linux.net/amd64-usr/${flatcar_version}/flatcar_production_image.bin.bz2.sig"
      }

      artifact {
        source = "https://stable.release.flatcar-linux.net/amd64-usr/${flatcar_version}/flatcar_production_pxe_image.cpio.gz"
        options {
          archive = false
        }
      }

      artifact {
        source = "https://stable.release.flatcar-linux.net/amd64-usr/${flatcar_version}/flatcar_production_pxe_image.cpio.gz.sig"
      }

      artifact {
        source = "https://stable.release.flatcar-linux.net/amd64-usr/${flatcar_version}/flatcar_production_pxe.vmlinuz"
      }

      artifact {
        source = "https://stable.release.flatcar-linux.net/amd64-usr/${flatcar_version}/flatcar_production_pxe.vmlinuz.sig"
      }

      artifact {
        source = "https://stable.release.flatcar-linux.net/amd64-usr/${flatcar_version}/version.txt"
      }

      artifact {
        source = "https://factory.talos.dev/image/${talos_schematic_id}/${talos_version}/kernel-amd64"
      }

      artifact {
        source = "https://factory.talos.dev/image/${talos_schematic_id}/${talos_version}/initramfs-amd64.xz"
        options {
          archive = false
        }
      }
    }
  }
}
