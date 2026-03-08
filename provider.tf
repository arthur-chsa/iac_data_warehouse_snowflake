terraform {
  required_version = ">= 1.5.0"

  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.95"
    }
  }
}

provider "snowflake" {
  organization_name      = var.snowflake_organization_name
  account_name           = var.snowflake_account_name
  user                   = var.snowflake_username
  authenticator          = "JWT"
  private_key            = var.snowflake_private_key
  private_key_passphrase = var.snowflake_private_key_passphrase
  role                   = var.snowflake_role
}
