resource "google_bigquery_dataset" "dataset" {
  project    = var.project_id
  dataset_id = var.dataset_id
  location   = var.region
  labels     = var.dataset_labels

  lifecycle {
    prevent_destroy = true
  }
}
