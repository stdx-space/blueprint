# Terraform module for self hosting Ory Hydra and Kratos on Nomad

### Usage

```hcl
module "ory" {
  source                 = "registry.narwhl.workers.dev/stack/idp/nomad"
  datacenter_name        = "dc1" # name of the datacenter in Nomad
  database_user          = "ory" # optional field, defaults to "ory", need to configure externally since db is not hosted from within this module
  database_password      = "my_secret_password" # required field, a single user will manages both hydra and kratos simultaneously
  database_addr          = "{ip_or_hostname}:{port}" # required field
  hydra_db_name          = "hydra" # optional field, defaults to "hydra"
  kratos_db_name         = "kratos" # optional field, defaults to "kratos"
  hydra_version          = "" # required field, should obtain this from oci image tag from registry
  kratos_version         = "" # required field, should obtain this from oci image tag from registry
  application_name       = "Acme Signle Sign-on" # required field
  root_domain            = "domain.tld" # required field, for composing subdomains that both hydra and kratos uses for its services
  hydra_subdomain        = "auth" # required field, for oauth server
  kratos_ui_subdomain    = "login" # required field, for idp login page, instance runs externally
  kratos_admin_subdomain = "accounts" # required field, for idp admin api
  smtp_connection_uri    = "smtp://{user:password}@{host:port}" # required field, http config for mail gateway tbd

  # optional: customize password policy (defaults shown below)
  kratos_password_policy = {
    min_password_length                 = 8
    haveibeenpwned_enabled              = true
    identifier_similarity_check_enabled = true
  }
}
```

## Argument Reference

- `datacenter_name`: `(string: <required>)` - The name of the Nomad datacenter to use.

- `namespace`: `(string: <optional>)` - The namespace to run the job in. Defaults to `default`.

- `job_name`: `(string: <optional>)` - The name of the job. Defaults to `ory`.

- `database_addr`: `(string: <required>)` - The address of the Postgres database.

- `database_password`: `(string: <required>)` - The password of the Postgres database.

- `database_sslmode`: `(string: <optional>)` - The ssl mode of the Postgres database. Defaults to `disable`.

- `database_user`: `(string: <optional>)` - The username of the Postgres database. Defaults to `ory`.

- `hydra_db_name`: `(string: <optional>)` - The name of the hydra database. Defaults to `hydra`.

- `kratos_db_name`: `(string: <optional>)` - The name of the kratos database. Defaults to `kratos`.

- `hydra_version`: `(string: <required>)` - The version of Ory Hydra to run.

- `kratos_version`: `(string: <required>)` - The version of Ory Kratos to run.

- `application_name`: `(string: <required>)` - The name of the application.

- `root_domain`: `(string: <required>)` - The root domain for the subdomains.

- `hydra_subdomain`: `(string: <required>)` - The subdomain for the hydra service.

- `kratos_ui_subdomain`: `(string: <required>)` - The subdomain for the kratos ui service.

- `kratos_admin_subdomain`: `(string: <required>)` - The subdomain for the kratos admin service.

- `smtp_connection_uri`: `(string: <required>)` - The smtp connection uri for sending emails.

- `kratos_identity_schema`: `(string: <required>)` - The identity schema for kratos.

- `kratos_recovery_enabled`: `(bool: <optional>)` - Whether to enable account recovery. Defaults to `true`.

- `kratos_verification_enabled`: `(bool: <optional>)` - Whether to enable account verification. Defaults to `true`.

- `kratos_webauthn_enabled`: `(bool: <optional>)` - Whether to enable webauthn. Defaults to `false`.

- `kratos_passkey_enabled`: `(bool: <optional>)` - Whether to enable passkey. Defaults to `false`.

- `kratos_password_policy`: `(object: <optional>)` - Password policy configuration for Kratos. Defaults to secure settings recommended by Kratos.
  - `min_password_length`: `(number)` - Minimum password length. Defaults to `8`. Must be at least `6`.
  - `haveibeenpwned_enabled`: `(bool)` - Whether to check passwords against HaveIBeenPwned API. Defaults to `true`.
  - `identifier_similarity_check_enabled`: `(bool)` - Whether to check password similarity to user identifier. Defaults to `true`.

- `email_from_name`: `(string: <required>)` - The name of the email sender.

- `registration_webhooks`: `([]object: <optional>)` - The registration webhooks.

- `settings_webhooks`: `([]object: <optional>)` - The settings webhooks.

- `traefik_entrypoints`: `(object: <optional>)` - The entrypoints to expose the service.

## Outputs

- `kratos_cookie_secret`: `string` - The cookie secret for Ory Kratos.
