# Job Configuration
job_name           = "spanner-to-bigquery"
template_gcs_path  = "gs://dataflow-templates-us-central1/2024-12-03-00_RC00/flex/Spanner_Change_Streams_to_BigQuery"
parameters = {
  spannerInstanceId          = "sample-instance"
  spannerDatabase            = "audit-db"
  spannerMetadataInstanceId  = "sample-instance"
  spannerMetadataDatabase    = "audit-db"
  spannerChangeStreamName    = "audit_db_change_stream"
  bigQueryDataset            = "audit_service_dataset"
  bigQueryChangelogTableNameTemplate = "{_metadata_spanner_table_name}_changelog"
}

# Networking Configuration
network_name         = "custom-dataflow-network"        # Default network for standalone projects
subnetwork_name      = "custom-dataflow-subnet"               # Use default subnetwork if not specified

# Storage Configuration
temp_bucket_name     = "dataflow-temp-spanner-bq-12345" # Unique GCS bucket name

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
