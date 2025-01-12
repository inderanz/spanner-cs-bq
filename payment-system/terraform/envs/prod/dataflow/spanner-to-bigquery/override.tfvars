# Job Configuration
job_name           = "spanner-to-bigquery-shared-db"
template_gcs_path  = "gs://dataflow-templates-us-central1/2024-12-03-00_RC00/flex/Spanner_Change_Streams_to_BigQuery"
parameters = {
  spannerInstanceId          = "sample-instance"
  spannerDatabase            = "shared-db"
  spannerMetadataInstanceId  = "sample-instance"
  spannerMetadataDatabase    = "shared-db"
  spannerChangeStreamName    = "shared_audit_db_cs" 
  bigQueryDataset            = "audit_service_dataset"
  bigQueryChangelogTableNameTemplate = "payment_audit_trail_changelog"
}

# Networking Configuration
network_name         = "custom-dataflow-network"        
subnetwork_name      = "custom-dataflow-subnet"              

# Storage Configuration
temp_bucket_name     = "dataflow-temp-spanner-bq-shared-db"

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
