output "dataset_id" {
  description = "The ID of the created BigQuery dataset."
  value       = module.bigquery.dataset_id
}

output "table_ids" {
  description = "List of created BigQuery table IDs."
  value       = module.bigquery.table_ids
}
