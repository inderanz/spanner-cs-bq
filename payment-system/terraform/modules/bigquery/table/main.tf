resource "google_bigquery_table" "tables" {
  for_each = { for t in var.table_definitions : t.table_id => t }

  project    = var.project_id
  dataset_id = var.dataset_id
  table_id   = each.value.table_id

  schema = file(each.value.schema)
  labels = each.value.labels

  clustering = each.value.clustering

  dynamic "time_partitioning" {
    for_each = each.value.partitioning != null ? [each.value.partitioning] : []
    content {
      type          = time_partitioning.value.type
      field         = time_partitioning.value.field
      expiration_ms = time_partitioning.value.expiration_ms
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
