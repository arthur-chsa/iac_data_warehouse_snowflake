# ─── Provider ────────────────────────────────────────────────────────────────

variable "snowflake_account" {
  description = "Snowflake account identifier (e.g. xy12345.us-east-1)"
  type        = string
}

variable "snowflake_username" {
  description = "Snowflake username used by Terraform"
  type        = string
}

variable "snowflake_private_key" {
  description = "PEM content of the private key. Locally: export TF_VAR_snowflake_private_key=\"$(cat keys/rsa_key.p8)\". In TFC: set as a sensitive Terraform variable."
  type        = string
  sensitive   = true
}

variable "snowflake_private_key_passphrase" {
  description = "Passphrase for the private key, if it was generated with one. Omit if the key has no passphrase."
  type        = string
  sensitive   = true
  default     = null
}

variable "snowflake_role" {
  description = "Snowflake role used by Terraform to provision resources (should be SYSADMIN or ACCOUNTADMIN)"
  type        = string
  default     = "SYSADMIN"
}

# ─── Roles ───────────────────────────────────────────────────────────────────

variable "roles" {
  description = <<-EOT
    Map of account roles to create. Key is the role name.
    granted_to_roles: list of existing roles that will receive this role (role hierarchy).
  EOT
  type = map(object({
    comment          = optional(string, "")
    granted_to_roles = optional(list(string), [])
  }))
  default = {}
}

# ─── Warehouses ──────────────────────────────────────────────────────────────

variable "warehouses" {
  description = <<-EOT
    Map of warehouses to create. Key is the warehouse name.
    grants: list of {privileges, roles} pairs to grant on this warehouse.
  EOT
  type = map(object({
    warehouse_size      = optional(string, "XSMALL")
    auto_suspend        = optional(number, 60)
    auto_resume         = optional(bool, true)
    initially_suspended = optional(bool, true)
    comment             = optional(string, "")
    grants = optional(list(object({
      privileges = list(string)
      roles      = list(string)
    })), [])
  }))
  default = {}
}

# ─── Users ───────────────────────────────────────────────────────────────────

variable "users" {
  description = <<-EOT
    Map of users to create. Key is the login name.
    roles: list of account roles to grant to this user.
  EOT
  type = map(object({
    display_name         = optional(string, "")
    email                = optional(string, "")
    default_role         = optional(string, "PUBLIC")
    default_warehouse    = optional(string, "")
    must_change_password = optional(bool, true)
    password             = optional(string, null)
    comment              = optional(string, "")
    roles                = optional(list(string), [])
  }))
  default = {}
}

# ─── Databases ───────────────────────────────────────────────────────────────

variable "databases" {
  description = <<-EOT
    Map of databases to create. Key is the database name.
    grants: list of {privileges, roles} pairs to grant on this database.
  EOT
  type = map(object({
    comment = optional(string, "")
    grants = optional(list(object({
      privileges = list(string)
      roles      = list(string)
    })), [])
  }))
  default = {}
}
