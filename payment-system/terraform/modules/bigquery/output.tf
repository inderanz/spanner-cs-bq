#output "dataset_location" {
#  description = "The location of the created BigQuery dataset."
#  value       = module.bigquery_dataset.location
#}

output "table_ids" {
  description = "List of created BigQuery table IDs."
  value       = module.bigquery_table.table_ids
}

output "access_roles" {
  description = "IAM roles applied to the BigQuery dataset."
  value       = module.bigquery_access.access_roles
}


output "dataset_id" {
  description = "The ID of the BigQuery dataset."
  value       = module.bigquery_dataset.dataset_id
}
