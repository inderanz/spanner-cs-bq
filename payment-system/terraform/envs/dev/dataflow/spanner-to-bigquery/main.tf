module "dataflow" {
  source             = "../../../../modules/dataflow"
  project_id         = var.project_id
  region             = var.region
  job_name           = var.job_name
  template_gcs_path  = var.template_gcs_path
  parameters         = merge(var.parameters, var.additional_parameters)
  service_account    = var.service_account
  network_name       = var.network_name
  subnetwork_name    = var.subnetwork_name
  temp_bucket_name   = var.temp_bucket_name
  labels             = var.labels
  additional_parameters = var.additional_parameters
  spanner_instance_id    = var.spanner_instance_id
  spanner_database       = var.spanner_database
  spanner_change_stream  = var.spanner_change_stream
  bigquery_dataset       = var.bigquery_dataset
  bigquery_table_template = var.bigquery_table_template
}
