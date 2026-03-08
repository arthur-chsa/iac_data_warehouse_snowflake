# ─── Roles ───────────────────────────────────────────────────────────────────

resource "snowflake_role" "this" {
  for_each = var.roles

  name    = each.key
  comment = each.value.comment
}

resource "snowflake_grant_account_role" "role_hierarchy" {
  for_each = local.role_hierarchy_grants

  role_name        = each.value.role_name
  parent_role_name = each.value.parent_role

  depends_on = [snowflake_role.this]
}

# ─── Warehouses ──────────────────────────────────────────────────────────────

resource "snowflake_warehouse" "this" {
  for_each = var.warehouses

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

  depends_on = [snowflake_warehouse.this, snowflake_role.this]
}

# ─── Users ───────────────────────────────────────────────────────────────────

resource "snowflake_user" "this" {
  for_each = var.users

  name                 = each.key
  login_name           = each.key
  display_name         = each.value.display_name
  email                = each.value.email
  default_role         = each.value.default_role
  default_warehouse    = each.value.default_warehouse
  must_change_password = each.value.must_change_password
  password             = each.value.password
  comment              = each.value.comment

  depends_on = [snowflake_role.this, snowflake_warehouse.this]
}

resource "snowflake_grant_account_role" "user_roles" {
  for_each = local.user_role_grants

  role_name = each.value.role_name
  user_name = each.value.user_name

  depends_on = [snowflake_user.this, snowflake_role.this]
}

# ─── Databases ───────────────────────────────────────────────────────────────

resource "snowflake_database" "this" {
  for_each = var.databases

  name    = each.key
  comment = each.value.comment
}

resource "snowflake_grant_privileges_to_account_role" "database" {
  for_each = local.database_grants

  account_role_name = each.value.role_name
  privileges        = each.value.privileges

  on_account_object {
    object_type = "DATABASE"
    object_name = each.value.db_name
  }

  depends_on = [snowflake_database.this, snowflake_role.this]
}
