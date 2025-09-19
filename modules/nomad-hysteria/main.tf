locals {
  hysteria_config = {
    listen : ":${var.listen_port}"
    tls : {
      cert : "/hysteria.crt"
      key : "/hysteria.key"
    }
    auth : {
      type : "password"
      password : var.auth_password
    }
    masquerade : {
      type : "proxy"
      proxy : {
        url : var.masquerade_url
        rewriteHost : true
      }
    }
    obfs : {
      type : var.obfs_type
      salamander : {
        password : var.obfs_password
      }
    }
  }
}

resource "tls_private_key" "hysteria" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "hysteria" {
  private_key_pem = tls_private_key.hysteria.private_key_pem

  subject {
    common_name  = var.cert_common_name
    organization = var.cert_organization
  }

  validity_period_hours = var.cert_ttl

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "nomad_job" "hysteria" {
  jobspec = templatefile("${path.module}/templates/hysteria.nomad.hcl", {
    job_name        = var.job_name
    datacenter      = var.datacenter_name
    namespace       = var.namespace
    version         = var.image_version
    key             = tls_private_key.hysteria.private_key_pem
    cert            = tls_self_signed_cert.hysteria.cert_pem
    key_path        = local.hysteria_config.tls.key
    cert_path       = local.hysteria_config.tls.cert
    hysteria_config = yamlencode(local.hysteria_config)
    listen_port     = var.listen_port
    bind_port       = var.bind_port
  })
  purge_on_destroy = var.purge_on_destroy
}
