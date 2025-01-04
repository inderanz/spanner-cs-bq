output "table_ids" {
  description = "List of created BigQuery table IDs."
  value       = [for table in google_bigquery_table.tables : table.id]
}

output "table_names" {
  description = "List of created BigQuery table names."
  value       = [for table in google_bigquery_table.tables : table.table_id]
}

output "schema_files" {
  description = "Schema files used for the tables."
  value       = [for table in google_bigquery_table.tables : table.schema]
}

output "partitioning_info" {
  description = "Partitioning configuration for each table."
  value = [
    for table in google_bigquery_table.tables : {
      table_id       = table.table_id
      partition_type = try(table.time_partitioning[0].type, null)
      partition_field = try(table.time_partitioning[0].field, null)
      expiration_ms   = try(table.time_partitioning[0].expiration_ms, null)
    }
  ]
}
