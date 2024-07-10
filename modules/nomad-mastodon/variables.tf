variable "datacenter_name" {
  type        = string
  description = "Name of the datacenter"
  validation {
    condition     = length(var.datacenter_name) > 0
    error_message = "Datacenter name cannot be empty"
  }
}

variable "job_name" {
  default = "mastodon"
}

variable "init_job_name" {
  default = "mastodon-init"
}

variable "mastodon_hostname" {
  default = "mastodon.localhost"
}

variable "mastodon_version" {
  default = "v4.2.9"
}

variable "redis_host" {
  default = "{{ env `NOMAD_UPSTREAM_IP_redis` }}"
}

variable "redis_port" {
  default = "{{ env `NOMAD_UPSTREAM_PORT_redis` }}"
}

variable "db_host" {
  default = "{{ env `NOMAD_UPSTREAM_IP_postgres` }}"
}

variable "db_port" {
  default = "{{ env `NOMAD_UPSTREAM_PORT_postgres` }}"
}

variable "db_user" {
  default = "mastodon"
}

variable "db_pass" {
  default   = "mastodon"
  sensitive = true
}

variable "db_name" {
  default = "mastodon_production"
}

variable "s3_endpoint" {
  default = "http://{{ env `NOMAD_UPSTREAM_ADDR_minio` }}"
}

variable "s3_bucket" {
  default = "mastodata"
}

variable "s3_access_key" {
  default = "mastodon"
}

variable "s3_secret_key" {
  default   = "mastodon"
  sensitive = true
}

variable "s3_hostname" {
  default = "files.mastodon.localhost"
}

variable "oidc_config" {
  type = object({
    display_name  = string
    issuer        = string
    client_id     = string
    client_secret = string
  })
  sensitive = true
}

variable "vapid_key" {
  type = object({
    public_key  = string
    private_key = string
  })
  sensitive   = true
  description = "Generate with `rake mastodon:webpush:generate_vapid_key`"
}
