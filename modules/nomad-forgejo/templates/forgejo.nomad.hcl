job "${job_name}" {
  datacenters = ["${datacenter}"]
  namespace   = "${namespace}"
  group "forgejo" {
    network {
      mode = "bridge"
      port "forgejo" {
        to = 3000
      }
      port "ssh" {
        to = 22
      }
    }
    service {
      name = "${job_name}"
      port = "forgejo"
      task = "forgejo"
      provider = "${service_discovery_provider}"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${job_name}.rule=Host(`${domain}`)",
        "traefik.http.routers.${job_name}.entrypoints=${traefik_entrypoints.http}",
        "traefik.http.routers.${job_name}-secure.rule=Host(`${domain}`)",
        "traefik.http.routers.${job_name}-secure.entrypoints=${traefik_entrypoints.https}",
        "traefik.http.routers.${job_name}-secure.tls=true",
      ]
      check {
        type     = "http"
        path     = "/api/healthz"
        interval = "10s"
        timeout  = "2s"
        port     = "forgejo"
      }
    }
    service {
      name = "${job_name}-ssh"
      port = "ssh"
      task = "forgejo"
      provider = "${service_discovery_provider}"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.${job_name}-ssh.entrypoints=${traefik_entrypoints.ssh}",
      ]
    }
    task "forgejo-restore" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
      driver = "docker"
      config {
        image = "restic/restic:${restic_version}"
        entrypoint = ["/bin/sh"]
        args = ["/local/entrypoint.sh"]
      }
      template {
        data = <<EOH
${restore_entrypoint_script}
        EOH
        destination = "local/entrypoint.sh"
      }
      template {
        data = <<EOH
${restic_env}
        EOH
        destination = "secrets/.env"
        env         = true
      }
    }
    task "litestream-restore" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
      driver = "docker"
      config {
        image = "litestream/litestream:${litestream_version}"
        args = [
          "restore",
          "-config",
          "/secrets/litestream.yml",
          "-if-replica-exists",
          "/alloc/forgejo.db",
        ]
      }
      user = "1000:1000"
      template {
        data = <<EOH
${litestream_config}
        EOH
        destination = "secrets/litestream.yml"
      }
    }
    task "forgejo" {
      driver = "docker"

      config {
        image = "codeberg.org/forgejo/forgejo:${forgejo_version}"
      }

      template {
        data = <<EOH
${forgejo_env}
        EOH
        destination = "secrets/.env"
        env         = true
      }

      resources {
        cpu    = ${resources.cpu}
        memory = ${resources.memory}
      }
    }
    task "litestream" {
      driver = "docker"
      config {
        image = "litestream/litestream:${litestream_version}"
        args = [
          "replicate",
          "-config",
          "/secrets/litestream.yml",
        ]
      }
      user = "1000:1000"
      template {
        data = <<EOH
${litestream_config}
        EOH
        destination = "secrets/litestream.yml"
      }
    }
    task "forgejo-backup" {
      driver = "docker"
      config {
        image = "restic/restic:${restic_version}"
        entrypoint = ["/bin/sh"]
        args = ["/local/entrypoint.sh"]
      }
      template {
        data = <<EOH
${backup_entrypoint_script}
        EOH
        destination = "local/entrypoint.sh"
      }
      template {
        data = <<EOH
${crontab}
        EOH
        destination = "local/crontabs/root"
      }
      template {
        data = <<EOH
${restic_env}
        EOH
        destination = "secrets/.env"
        env         = true
      }
    }
  }
}
