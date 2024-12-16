job "vault" {
  datacenters = ["default"]
  type        = "service"

  group "vault" {

    ephemeral_disk {
      migrate = true
      size    = 64
      sticky  = true
    }

    network {
      mode = "bridge"
      port "dns" {}
    }

    task "coredns" {
      driver = "docker"

      config {
        image = "coredns/coredns:${coredns_version}"
        args  = ["-conf", "$${NOMAD_ALLOC_DIR}/Corefile"]
      }

      template {
        destination = "$${NOMAD_ALLOC_DIR}/Corefile"
        change_mode = "restart"
        data = <<-EOF
        ${domain}:53 {
          errors
          health
          log stdout
          hosts {
            {{ env "NOMAD_ALLOC_IP_dns" }} vault.${domain}
            fallthrough
          }
          forward . 1.1.1.1:53 8.8.8.8:53
          reload
        }
        EOF
      }
    }

    task "tailscale" {
      driver = "docker"

      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      config {
        image = "tailscale/tailscale:stable" 
      }

      template {
        data = <<-EOH
        TS_AUTHKEY=${tailscale_authkey} 
        TS_STATE_DIR="{{ env "NOMAD_ALLOC_DIR" }}/data/tailscale"
        TS_USERSPACE="true"
        TS_HOSTNAME="{{ env "NOMAD_GROUP_NAME" }}"
        TS_ROUTES="{{ env "NOMAD_ALLOC_IP_dns" }}/32"
        EOH
        destination = "secrets/file.env"
        env         = true
      }
    }

    task "vault" {
      driver = "docker"

      config {
        image = "hashicorp/vault:${vault_version}"

        args = [
          "server",
          "-config=$${NOMAD_SECRETS_DIR}/vault.hcl"
        ]

        cap_add = ["ipc_lock"]
      }

      template {
        destination = "$${NOMAD_SECRETS_DIR}/vault.hcl"
        change_mode = "noop"
        data = <<EOF
        ui               = true
        api_addr         = "https://127.0.0.1:8200"
        cluster_addr     = "https://127.0.0.1:8201"
        disable_mlock    = true
        log_level        = "${log_level}"
        plugin_directory = "/etc/vault.d/plugins"
        storage "s3" {
          access_key          = "${access_key}"
          secret_key          = "${secret_key}"
          endpoint            = "${endpoint}"
          bucket              = "${bucket}"
          s3_force_path_style = true
        }

        listener "tcp" {
          address        = "0.0.0.0:8200"
          tls_cert_file  = "{{ env "NOMAD_SECRETS_DIR" }}/cert.pem"
          tls_key_file   = "{{ env "NOMAD_SECRETS_DIR" }}/key.pem"
        }
        EOF
      }

      template {
        destination = "$${NOMAD_SECRETS_DIR}/cert.pem"
        change_mode = "restart"
        data = <<-EOF

        EOF
      }

      template {
        destination = "$${NOMAD_SECRETS_DIR}/key.pem"
        change_mode = "restart"
        data = <<-EOF

        EOF
      }

      resources {
        cpu    = 500
        memory = 1024
      }
    }
  }
}
