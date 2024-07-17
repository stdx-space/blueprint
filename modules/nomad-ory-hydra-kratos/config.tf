locals {
  kratos_config = yamlencode({
    identity = {
      default_schema_id = "default"
      schemas = [
        {
          id  = "default"
          url = "base64://${base64encode(var.kratos_identity_schema)}"
        }
      ]
    }
    serve = {
      public = {
        base_url = "https://${local.kratos_public_fqdn}" # TODO: make https and subpath configurable
        cors = {
          # https://www.ory.sh/docs/kratos/guides/setting-up-cors
          enabled = true
          allowed_origins = [
            "https://${var.root_domain}",
            "https://*.${var.root_domain}"
          ]
          allowed_methods = [
            "GET",
            "POST",
            "PUT",
            "PATCH",
            "DELETE"
          ]
          allowed_headers = [
            "Authorization",
            "Content-Type",
            "Cookie"
          ]
          exposed_headers = [
            "Set-Cookie",
            "Content-Type",
          ]
        }
      }
      admin = {
        base_url = "https://${local.kratos_admin_fqdn}" # TODO: make https and subpath configurable
      }
    }
    selfservice = {
      default_browser_return_url = local.kratos_ui_url
      allowed_return_urls = [
        local.kratos_ui_url
      ]
      methods = {
        password = {
          enabled = true
        }
        totp = {
          config = {
            issuer = var.application_name
          }
          enabled = true
        }
        lookup_secret = {
          enabled = true
        }
        link = {
          enabled = true
        }
        code = {
          enabled = true
        }
        webauthn = {
          enabled = true
          config = {
            passwordless = true
            rp = {
              display_name = var.application_name
              id           = var.root_domain
              origin       = local.kratos_ui_url
            }
          }
        }
      }

      flows = {
        error = {
          ui_url = "${local.kratos_ui_url}/error"
        }

        settings = {
          ui_url = "${local.kratos_ui_url}/settings"
        }

        recovery = {
          enabled = var.kratos_recovery_enabled
          ui_url  = "${local.kratos_ui_url}/recovery"
        }

        verification = {
          enabled = var.kratos_verification_enabled
          ui_url  = "${local.kratos_ui_url}/verification"

          after = {
            default_browser_return_url = local.kratos_ui_url
          }
        }

        logout = {
          after = {
            default_browser_return_url = "${local.kratos_ui_url}/login"
          }
        }

        login = {
          ui_url   = "${local.kratos_ui_url}/login"
          lifespan = "10m"
        }

        registration = {
          ui_url   = "${local.kratos_ui_url}/registration"
          lifespan = "10m"
          after = {
            password = {
              hooks = []
            }
          }
        }
      }
    }

    session = {
      cookie = {
        domain    = var.root_domain
        same_site = "Lax"
      }
    }

    cookies = {
      domain    = var.root_domain
      same_site = "Lax"
    }

    hashers = {
      algorithm = "bcrypt"
      bcrypt = {
        cost = 8
      }
    }

    ciphers = {
      alogrithm = "xchacha20-poly1305"
    }

    secrets = {
      cipher = [
        random_bytes.kratos_secret_cipher.hex
      ]
      cookie = [
        random_bytes.kratos_cookie_secret.hex
      ]
    }

    courier = {
      smtp = {
        connection_uri = var.smtp_connection_uri
      }
    }

    oauth2_provider = {
      url = "http://{{ range nomadService `hydra-admin` }}{{ .Address }}:{{ .Port }}{{ end }}"
    }
  })
  hydra_config = yamlencode({
    serve = {
      cookies = {
        same_site_mode = "Lax"
      }
    }

    urls = {
      self = {
        issuer = "https://${local.hydra_fqdn}"
      }
      consent = "${local.kratos_ui_url}/consent"
      login   = "${local.kratos_ui_url}/login"
      logout  = "${local.kratos_ui_url}/logout"
      identity_provider = {
        publicUrl = "https://${local.kratos_public_fqdn}" # TODO: make https configurable

        // headers = {
        //   "Authorization" = "Bearer ..."
        // }

        url = "http://{{ range nomadService `kratos-admin` }}{{ .Address }}:{{ .Port }}{{ end }}" # TODO: make https configurable
      }
    }

    secrets = {
      cookie = [
        random_bytes.hydra_cookie_secret.hex
      ]
      system = [
        random_bytes.hydra_system_secret.hex
      ]
    }

    oidc = {
      subject_identifiers = {
        supported_types = [
          "public",
          "pairwise"
        ]
        pairwise = {
          salt = random_bytes.hydra_oidc_pairwise_salt.hex
        }
      }
    }

    ttl = {
      access_token          = "1h"
      refresh_token         = "1h"
      id_token              = "1h"
      auth_code             = "1h"
      login_consent_request = "1h"
    }

    oauth2 = {
      session = {
        encrypt_at_rest = false
      }
      exclude_not_before_claim = true
    }

  })
}
