locals {
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
}
