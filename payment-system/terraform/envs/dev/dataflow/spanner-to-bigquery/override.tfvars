# Job Configuration
job_name           = "spanner-to-bigquery"
template_gcs_path  = "gs://dataflow-templates/latest/Spanner_Change_Stream_to_BigQuery"
parameters = {
  spannerInstanceId    = "spanner-instance"
  spannerDatabase      = "spanner-database"
  spannerChangeStream  = "change-stream"
  bigQueryDataset      = "dataset"
  bigQueryTableTemplate = "table-template"
}
additional_parameters = {
  additionalParam1 = "value1"
  additionalParam2 = "value2"
}

# Networking Configuration
network_name         = "default"        # Default network for standalone projects
subnetwork_name      = "dataflow-subnet"

# Storage Configuration
temp_bucket_name     = "dataflow-temp"

# Labels
labels = {
  environment = "dev"
  team        = "data"
  pipeline    = "spanner-to-bigquery"
}

# IAM Configuration
iam_roles = {
  "roles/dataflow.worker"      = true
  "roles/storage.objectAdmin"  = true
}

# General Configurations
project_id       = "spanner-gke-443910"
region           = "us-central1"
service_account  = "dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com"

# Spanner Configuration
spanner_instance_id    = "spanner-instance"
spanner_database       = "spanner-database"
spanner_change_stream  = "change-stream"

# BigQuery Configuration
bigquery_dataset       = "dataset"
bigquery_table_template = "table-template"
