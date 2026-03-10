locals {
  organization_name = "SLDGLDQ"
  account_name      = "IR60026"
  user              = "TERRAFORM_SA"
  role              = "ACCOUNTADMIN"
}

provider "snowflake" {
  organization_name      = local.organization_name
  account_name           = local.account_name
  user                   = local.user
  authenticator          = "JWT"
  private_key            = var.snowflake_private_key
  private_key_passphrase = var.snowflake_private_key_passphrase
  role                   = local.role
}

terraform {
  backend "gcs" {
    bucket = "terraform-states-egym-com-prod"
    prefix = "global/snowflake/databases"
  }
}

# ─── Variables ───────────────────────────────────────────────────────────────

variable "snowflake_private_key" {
  description = "PEM content of the private key. Export via: export TF_VAR_snowflake_private_key=\"$(cat keys/rsa_key.p8)\""
  type        = string
  sensitive   = true
}

variable "snowflake_private_key_passphrase" {
  description = "Passphrase for the private key, if any."
  type        = string
  sensitive   = true
  default     = null
}

locals {
  database_grants = {
    for pair in flatten([
      for db_name, db in local.databases : [
        for grant in db.grants : [
          for role in grant.roles : {
            key        = "${db_name}__${join("_", sort(grant.privileges))}__${role}"
            db_name    = db_name
            privileges = grant.privileges
            role_name  = role
          }
        ]
      ]
    ]) : pair.key => pair
  }
}

# ─── Resources ───────────────────────────────────────────────────────────────

resource "snowflake_database" "this" {
  for_each = local.databases

  name    = each.key
  comment = each.value.comment
}

resource "snowflake_grant_privileges_to_account_role" "database" {
  for_each = local.database_grants

  account_role_name = each.value.role_name
  privileges        = each.value.privileges

  on_account_object {
    object_type = "DATABASE"
    object_name = each.value.db_name
  }

  depends_on = [snowflake_database.this]
}
