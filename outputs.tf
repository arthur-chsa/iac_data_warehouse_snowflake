output "roles" {
  description = "Created Snowflake account roles"
  value       = { for k, v in snowflake_account_role.this : k => v.name }
}

output "warehouses" {
  description = "Created Snowflake warehouses"
  value       = { for k, v in snowflake_warehouse.this : k => v.name }
}

output "users" {
  description = "Created Snowflake users"
  value       = { for k, v in snowflake_user.this : k => v.name }
}

output "databases" {
  description = "Created Snowflake databases"
  value       = { for k, v in snowflake_database.this : k => v.name }
}
