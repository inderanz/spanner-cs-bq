resource "google_bigquery_dataset_access" "access" {
  for_each = {
    for role_config in var.access_roles : "${role_config.role}-${role_config.members[0]}" => role_config.members
  }

  dataset_id = var.dataset_id
  project    = var.project_id

  role           = each.key
  user_by_email  = each.value[0] # Extract the first (and only) element from the list
}
