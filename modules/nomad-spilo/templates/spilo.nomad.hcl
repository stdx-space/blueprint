job "${job_name}" {
  datacenters = ["${datacenter_name}"]
  type = "service"
  %{ for node in nodes}
  group "spilo-etcd-${node.short_name}" {

    constraint {
      attribute  = "$${node.unique.name}"
      value     = "${node.name}"
    }

    network {
      mode = "bridge"
      port "etcd-client" {
        to = 2379
      }
      port "etcd-peer" {
        to = 2380
      }
    }

    service {
      name     = "spilo-etcd-client"
      provider = "nomad"
      port     = "etcd-client"
      check {
        name     = "HTTP API Check"
        type     = "http"
        port     = "etcd-client"
        path     = "/health"
        interval = "5s"
        timeout  = "2s"
      }
    }

    service {
      name     = "spilo-${node.short_name}-etcd-client"
      provider = "nomad"
      port     = "etcd-client"
      check {
        name     = "HTTP API Check"
        type     = "http"
        port     = "etcd-client"
        path     = "/health"
        interval = "5s"
        timeout  = "2s"
      }
    }

    service {
      name     = "spilo-${node.short_name}-etcd-peer"
      provider = "nomad"
      port     = "etcd-peer"
    }

    task "etcd" {
      driver = "docker"

      config {
        image = "ghcr.io/zalando/${spilo_version}"
        command = "etcd"
      }

      template {
        data = <<-EOF
        ETCD_NAME="etcd-${node.short_name}"
        ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
        ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
        ETCD_ADVERTISE_CLIENT_URLS="{{ range nomadService `spilo-${node.short_name}-etcd-client` }}http://{{ .Address }}:{{ .Port }}{{ end }}"
        ETCD_INITIAL_CLUSTER="${etcd_cluster_http}"
        ETCD_INITIAL_ADVERTISE_PEER_URLS="{{ range nomadService `spilo-${node.short_name}-etcd-peer` }}http://{{ .Address }}:{{ .Port }}{{ end }}"
        ETCD_INITIAL_CLUSTER_STATE="new"
        EOF
        destination = "local/config.env"
        env = true
      }
    }

  }

  group "spilo-${node.short_name}" {

    constraint {
      attribute  = "$${node.unique.name}"
      value     = "${node.name}"
    }

    network {
      mode = "bridge"
      # port "etcd-client" {
      #   to = 2379
      #   static = 2379
      # }
      # port "etcd-peer" {
      #   to = 2380
      #   static = 2380
      # }
      port "postgres" {
        to     = 5432
        static = 5432
      }
      port "patroni" {
        to     = 8008
        static = 8008
      }
    }

    service {
      name     = "postgres-ro"
      port     = "postgres"
      check {
        name     = "connection_tcp"
        type     = "tcp"
        port     = 5432
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name     = "postgres-rw"
      port     = "postgres"
      check {
        name     = "connection_tcp"
        type     = "tcp"
        port     = 5432
        interval = "10s"
        timeout  = "2s"
      }
      check {
        name     = "master_check"
        type     = "http"
        path     = "/"
        port     = "patroni"
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name     = "spilo-${node.short_name}-patroni"
      port     = "patroni"
    }

    task "spilo" {
      driver = "docker"

      config {
        image = "ghcr.io/zalando/${spilo_version}"
      }

      template {
        data = <<-EOF
        AWS_ACCESS_KEY_ID=${s3_access_key}
        AWS_SECRET_ACCESS_KEY=${s3_secret_key}
        AWS_ENDPOINT=${s3_endpoint}
        AWS_S3_FORCE_PATH_STYLE=true
        BACKUP_SCHEDULE=${backup_schedule}
        WAL_S3_BUCKET="${wal_bucket}"
        ETCD_HOSTS="${etcd_cluster}"
        PGPASSWORD_SUPERUSER="${postgres_superuser_password}"
        PGUSER_SUPERUSER="${postgres_superuser_username}"
        SCOPE=default
        KUBERNETES_SERVICE_HOST="{{ range service "spilo-${node.short_name}-patroni" }}{{ .Address }}{{ end }}"
        POD_IP="{{ range service "spilo-${node.short_name}-patroni" }}{{ .Address }}{{ end }}"
        EOF
        destination = "local/config.env"
        env         = true
      }
    }
  }%{ endfor }
}
