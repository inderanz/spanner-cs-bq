resource "google_pubsub_topic" "topic" {
  name    = var.name
  project = var.project_id
  labels  = var.labels

  dynamic "schema_settings" {
    for_each = var.schema != null ? [var.schema] : []
    content {
      schema = schema_settings.value
    }
  }

  dynamic "message_storage_policy" {
    for_each = var.message_storage_policy != null ? [var.message_storage_policy] : []
    content {
      allowed_persistence_regions = message_storage_policy.value.allowed_persistence_regions
    }
  }
}
