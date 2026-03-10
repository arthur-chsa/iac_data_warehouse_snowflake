output "databases" {
  description = "Map of created Snowflake databases"
  value       = { for k, v in snowflake_database.this : k => v.name }
}
