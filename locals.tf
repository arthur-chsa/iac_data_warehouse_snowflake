locals {

  # ─── Role hierarchy: grant each role to its parent roles ───────────────────
  # Produces one entry per (child_role, parent_role) pair.
  role_hierarchy_grants = {
    for pair in flatten([
      for role_name, role in var.roles : [
        for parent in role.granted_to_roles : {
          key         = "${role_name}__to__${parent}"
          role_name   = role_name
          parent_role = parent
        }
      ]
    ]) : pair.key => pair
  }

  # ─── Warehouse grants: one entry per (warehouse, privilege_set, role) ──────
  warehouse_grants = {
    for pair in flatten([
      for wh_name, wh in var.warehouses : [
        for grant in wh.grants : [
          for role in grant.roles : {
            key            = "${wh_name}__${join("_", sort(grant.privileges))}__${role}"
            warehouse_name = wh_name
            privileges     = grant.privileges
            role_name      = role
          }
        ]
      ]
    ]) : pair.key => pair
  }

  # ─── User role grants: one entry per (user, role) pair ────────────────────
  user_role_grants = {
    for pair in flatten([
      for user_name, user in var.users : [
        for role in user.roles : {
          key       = "${user_name}__${role}"
          user_name = user_name
          role_name = role
        }
      ]
    ]) : pair.key => pair
  }

  # ─── Database grants: one entry per (database, privilege_set, role) ────────
  database_grants = {
    for pair in flatten([
      for db_name, db in var.databases : [
        for grant in db.grants : [
          for role in grant.roles : {
            key        = "${db_name}__${join("_", sort(grant.privileges))}__${role}"
            db_name    = db_name
            privileges = grant.privileges
            role_name  = role
          }
        ]
      ]
    ]) : pair.key => pair
  }
}
