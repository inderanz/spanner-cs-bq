module "dataflow_streaming" {
  source             = "../../"
  project_id         = "spanner-gke-443910"
  region             = "us-central1"
  job_name           = "spanner-to-bigquery-dev"
  template_gcs_path  = "gs://dataflow-templates/latest/Spanner_Change_Stream_to_BigQuery"
  parameters = var.parameters
  service_account    = "dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com"
  use_shared_vpc     = false
  network_name       = "default"
  subnetwork_name    = "default-subnet"
  temp_bucket_name   = "dataflow-temp-dev"
  labels = {
    environment = "dev"
    pipeline    = "spanner-to-bigquery"
    team        = "data"
  }
}
