output "roles" {
  description = "Map of created Snowflake account roles"
  value       = { for k, v in snowflake_account_role.this : k => v.name }
}
