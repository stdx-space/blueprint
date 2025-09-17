job "${job_name}" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "hysteria" {
    network {
      port "tls" {
        to     = ${listen_port}
        static = ${bind_port}
      }
    }

    task "hysteria" {
      resources {
        memory = 256
      }

      driver = "docker"

      config {
        image = "tobyxdd/hysteria:${version}"
        ports = ["tls"]
        args  = ["server", "-c", "/etc/hysteria.yaml"]

        mount {
          type   = "bind"
          source = "local/hysteria.yaml"
          target = "/etc/hysteria.yaml"
        }

        mount {
          type   = "bind"
          source = "local/hysteria.key"
          target = "${key_path}"
        }

        mount {
          type   = "bind"
          source = "local/hysteria.crt"
          target = "${cert_path}"
        }

      }

      template {
        destination = "local/hysteria.key"
        data = <<EOF
${key}
        EOF
      }

      template {
        destination = "local/hysteria.crt"
        data = <<EOF
${cert}
        EOF
      }

      template {
        destination = "local/hysteria.yaml"
        data = <<-EOF
${hysteria_config}
        EOF
      }
    }
  }
}
