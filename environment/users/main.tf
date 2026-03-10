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
    prefix = "global/snowflake/users"
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
  user_role_grants = {
    for pair in flatten([
      for user_name, user in local.users : [
        for role in user.roles : {
          key       = "${user_name}__${role}"
          user_name = user_name
          role_name = role
        }
      ]
    ]) : pair.key => pair
  }
}

# ─── Resources ───────────────────────────────────────────────────────────────

resource "snowflake_user" "this" {
  for_each = local.users

  name                 = each.key
  login_name           = each.key
  display_name         = each.value.display_name
  email                = each.value.email
  default_role         = each.value.default_role
  default_warehouse    = each.value.default_warehouse
  must_change_password = each.value.must_change_password
  password             = each.value.password
  comment              = each.value.comment
}

resource "snowflake_grant_account_role" "user_roles" {
  for_each = local.user_role_grants

  role_name = each.value.role_name
  user_name = each.value.user_name

  depends_on = [snowflake_user.this]
}
