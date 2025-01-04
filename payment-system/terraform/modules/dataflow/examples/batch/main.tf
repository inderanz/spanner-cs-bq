module "dataflow_batch" {
  source             = "../../"
  project_id         = "spanner-gke-443910"
  region             = "us-central1"
  job_name           = "batch-job-dev"
  template_gcs_path  = "gs://dataflow-templates/latest/Word_Count"
  parameters = {
    inputFile = "gs://dataflow-input-dev/input.txt"
    output    = "gs://dataflow-output-dev/output"
  }
  service_account    = "dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com"
  use_shared_vpc     = false
  network_name       = "default"
  subnetwork_name    = "default-subnet"
  temp_bucket_name   = "dataflow-temp-dev"
  labels = {
    environment = "dev"
    pipeline    = "batch-job"
    team        = "data"
  }
}
