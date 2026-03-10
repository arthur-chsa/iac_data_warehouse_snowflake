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
    prefix = "global/snowflake/roles"
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
  role_hierarchy_grants = {
    for pair in flatten([
      for role_name, role in local.roles : [
        for parent in role.granted_to_roles : {
          key         = "${role_name}__to__${parent}"
          role_name   = role_name
          parent_role = parent
        }
      ]
    ]) : pair.key => pair
  }
}

# ─── Resources ───────────────────────────────────────────────────────────────

resource "snowflake_account_role" "this" {
  for_each = local.roles

  name    = each.key
  comment = each.value.comment
}

resource "snowflake_grant_account_role" "role_hierarchy" {
  for_each = local.role_hierarchy_grants

  role_name        = each.value.role_name
  parent_role_name = each.value.parent_role

  depends_on = [snowflake_account_role.this]
}
