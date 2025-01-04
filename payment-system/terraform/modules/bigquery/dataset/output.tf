output "dataset_id" {
  description = "The ID of the created BigQuery dataset."
  value       = google_bigquery_dataset.dataset.dataset_id
}


output "self_link" {
  description = "The self link of the created BigQuery dataset."
  value       = google_bigquery_dataset.dataset.self_link
}

output "labels" {
  description = "Labels applied to the dataset."
  value       = google_bigquery_dataset.dataset.labels
}

output "location" {
  description = "The location of the created BigQuery dataset."
  value       = google_bigquery_dataset.dataset.location
}
