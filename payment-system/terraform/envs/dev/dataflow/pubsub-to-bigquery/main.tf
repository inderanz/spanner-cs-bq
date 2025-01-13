module "dataflow" {
  source             = "../../../../modules/dataflow"
  project_id         = var.project_id
  region             = var.region
  job_name           = var.job_name
  template_gcs_path  = var.template_gcs_path
  service_account    = var.service_account
  network_name       = var.network_name
  subnetwork_name    = var.subnetwork_name
  temp_bucket_name   = var.temp_bucket_name
  labels             = var.labels
  parameters         = merge(var.parameters, var.additional_parameters)
}
