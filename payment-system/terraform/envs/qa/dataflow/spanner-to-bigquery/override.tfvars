# Job Configuration
job_name           = "spanner-to-bigquery-qa"
template_gcs_path  = "gs://dataflow-templates-us-central1/2024-12-03-00_RC00/flex/Spanner_Change_Streams_to_BigQuery"
parameters = {
  spannerInstanceId          = "sample-instance"
  spannerDatabase            = "audit-db"
  spannerMetadataInstanceId  = "sample-instance"
  spannerMetadataDatabase    = "audit-db"
  spannerChangeStreamName    = "audit_db_change_stream_v2"
  bigQueryDataset            = "audit_service_dataset"
  bigQueryChangelogTableNameTemplate = "payment_audit_trail_changelog"
}

# Networking Configuration
network_name         = "custom-dataflow-network"        
subnetwork_name      = "custom-dataflow-subnet"              

# Storage Configuration
temp_bucket_name     = "dataflow-temp-spanner-bq-qa"

# Labels
labels = {
  environment = "qa"
  team        = "data-qa"
  pipeline    = "spanner-to-bigquery-qa"
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
