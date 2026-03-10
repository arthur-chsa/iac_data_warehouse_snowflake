output "users" {
  description = "Map of created Snowflake users"
  value       = { for k, v in snowflake_user.this : k => v.name }
}
