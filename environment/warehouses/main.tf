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
    prefix = "global/snowflake/warehouses"
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
  warehouse_grants = {
    for pair in flatten([
      for wh_name, wh in local.warehouses : [
        for grant in wh.grants : [
          for role in grant.roles : {
            key            = "${wh_name}__${join("_", sort(grant.privileges))}__${role}"
            warehouse_name = wh_name
            privileges     = grant.privileges
            role_name      = role
          }
        ]
      ]
    ]) : pair.key => pair
  }
}

# ─── Resources ───────────────────────────────────────────────────────────────

resource "snowflake_warehouse" "this" {
  for_each = local.warehouses

  name                = each.key
  warehouse_size      = each.value.warehouse_size
  auto_suspend        = each.value.auto_suspend
  auto_resume         = each.value.auto_resume
  initially_suspended = each.value.initially_suspended
  comment             = each.value.comment
}

resource "snowflake_grant_privileges_to_account_role" "warehouse" {
  for_each = local.warehouse_grants

  account_role_name = each.value.role_name
  privileges        = each.value.privileges

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = each.value.warehouse_name
  }

  depends_on = [snowflake_warehouse.this]
}
