# This file has values for the corresponding environment, and should be assign to the workspace
# It is part of the repo, so it should not have secret values

snowflake_account           = "SLDGLDQ-IR60026.snowflakecomputing.com"
snowflake_username          = "TERRAFORM_SA"
snowflake_role              = "ACCOUNTADMIN"

# ─── Roles ───────────────────────────────────────────────────────────────────
# granted_to_roles: existing roles that will receive this role (role hierarchy).

roles = {
  "LOADING_RL" = {
    comment          = "Data ingestion — granted to service accounts and data engineers"
    granted_to_roles = ["SYSADMIN", "DATA_ENGINEERING_RL"]
  }
  "TRANSFORMATION_RL" = {
    comment          = "dbt transformations — granted to service accounts and data engineers"
    granted_to_roles = ["SYSADMIN", "DATA_ENGINEERING_RL"]
  }
  "READING_PRODUCT_RL" = {
    comment          = "Read access to product datamarts"
    granted_to_roles = ["SYSADMIN", "BI_ANALYST_RL"]
  }
  "READING_MARKETING_RL" = {
    comment          = "Read access to marketing datamarts"
    granted_to_roles = ["SYSADMIN", "BI_ANALYST_RL"]
  }
  "DATA_ENGINEERING_RL" = {
    comment          = "Data engineers — inherits loading and transformation roles"
    granted_to_roles = ["SYSADMIN"]
  }
  "BI_ANALYST_RL" = {
    comment          = "BI analysts — inherits product and marketing reading roles"
    granted_to_roles = ["SYSADMIN"]
  }
}

# ─── Warehouses ──────────────────────────────────────────────────────────────
# Defaults: warehouse_size = XSMALL, auto_suspend = 60, auto_resume = true, initially_suspended = true
# grants: list of privilege/role pairs to assign on this warehouse.

warehouses = {
  "LOADING_WH" = {
    comment = "Warehouse for data ingestion"
    grants = [
      { privileges = ["USAGE"], roles = ["LOADING_RL"] },
    ]
  }
  "TRANSFORMATION_WH" = {
    comment = "Warehouse for dbt runs"
    grants = [
      { privileges = ["USAGE"], roles = ["TRANSFORMATION_RL"] },
    ]
  }
  "READING_WH" = {
    comment = "Warehouse for BI queries"
    grants = [
      { privileges = ["USAGE"], roles = ["READING_PRODUCT_RL", "READING_MARKETING_RL"] },
    ]
  }
}

# ─── Users ───────────────────────────────────────────────────────────────────
# roles: account roles to grant to this user.
# depends on: roles and warehouses defined above.

users = {
  "FIVETRAN_USER" = {
    display_name         = "Fivetran Service Account"
    email                = "fivetran@company.com"
    default_role         = "LOADING_RL"
    default_warehouse    = "LOADING_WH"
    must_change_password = false
    password             = "changeme"
    comment              = "Service account for Fivetran"
    roles                = ["LOADING_RL"]
  }
  "DBT_USER" = {
    display_name         = "dbt Service Account"
    email                = "dbt@company.com"
    default_role         = "TRANSFORMATION_RL"
    default_warehouse    = "TRANSFORMATION_WH"
    must_change_password = false
    password             = "changeme"
    comment              = "Service account for dbt"
    roles                = ["TRANSFORMATION_RL"]
  }
}

# ─── Databases ───────────────────────────────────────────────────────────────
# grants: list of privilege/role pairs to assign on this database.
# depends on: roles defined above.

databases = {
  "LOADING_DB" = {
    comment = "Landing zone for raw ingested data"
    grants = [
      { privileges = ["USAGE", "CREATE SCHEMA"], roles = ["LOADING_RL"] },
      { privileges = ["USAGE"],                  roles = ["TRANSFORMATION_RL"] },
    ]
  }
  "TRANSFORMATION_DB" = {
    comment = "Intermediate and modelled data — dbt workspace"
    grants = [
      { privileges = ["USAGE", "CREATE SCHEMA"], roles = ["TRANSFORMATION_RL"] },
      { privileges = ["USAGE"],                  roles = ["LOADING_RL"] },
    ]
  }
  "DATAMARTS_DB" = {
    comment = "Business-facing datamarts consumed by BI tools"
    grants = [
      { privileges = ["USAGE", "CREATE SCHEMA"], roles = ["TRANSFORMATION_RL"] },
      { privileges = ["USAGE"],                  roles = ["READING_PRODUCT_RL", "READING_MARKETING_RL"] },
    ]
  }
}
