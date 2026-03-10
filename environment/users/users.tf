locals {
  users = {
    "FIVETRAN_USER" = {
      display_name         = "Fivetran Service Account"
      email                = "fivetran_service_account@egym.com"
      default_role         = "LOADING_RL"
      default_warehouse    = "LOADING_WH"
      must_change_password = false
      password             = "changeme"
      comment              = "Service account for Fivetran"
      roles                = ["LOADING_RL"]
    }
    "DBT_USER" = {
      display_name         = "dbt Service Account"
      email                = "dbt_service_account@egym.com"
      default_role         = "TRANSFORMATION_RL"
      default_warehouse    = "TRANSFORMATION_WH"
      must_change_password = false
      password             = "changeme"
      comment              = "Service account for dbt"
      roles                = ["TRANSFORMATION_RL"]
    }
  }
}
