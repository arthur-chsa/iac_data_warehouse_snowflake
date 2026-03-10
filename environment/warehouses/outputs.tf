output "warehouses" {
  description = "Map of created Snowflake warehouses"
  value       = { for k, v in snowflake_warehouse.this : k => v.name }
}
