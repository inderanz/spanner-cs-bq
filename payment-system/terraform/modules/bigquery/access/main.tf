resource "google_bigquery_dataset_access" "access" {
  for_each = {
    for role_config in var.access_roles : "${role_config.role}-${index(role_config.members, role_config.members[0])}" => role_config
  }

  dataset_id = var.dataset_id
  project    = var.project_id

  role = each.value.role

  # Determine member type
  user_by_email = !startswith(each.value.members[0], "serviceAccount:") ? replace(each.value.members[0], "user:", "") : null
  iam_member    = startswith(each.value.members[0], "serviceAccount:") ? each.value.members[0] : null
}
