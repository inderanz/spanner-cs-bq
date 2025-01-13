# Job Configuration
job_name           = "pubsub-to-bigquery"
template_gcs_path  = "gs://dataflow-templates-us-central1/latest/flex/PubSub_to_BigQuery_Flex"
parameters = {
  inputTopic            = "projects/spanner-gke-443910/topics/spanner-change-streams-topic"
  outputTableSpec       = "spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog"
  outputDeadletterTable = "spanner-gke-443910:audit_service_dataset.payment_audit_dlq"
}

# Networking Configuration
network_name         = "custom-dataflow-network"
subnetwork_name      = "custom-dataflow-subnet"

# Storage Configuration
temp_bucket_name     = "dataflow-temp-pubsub-bq-dev"

# Labels
labels = {
  environment = "dev"
  team        = "data"
  pipeline    = "pubsub-to-bigquery"
}

# IAM Configuration
iam_roles = {
  "roles/dataflow.worker"      = true
  "roles/storage.objectAdmin"  = true
  "roles/pubsub.subscriber"    = true
  "roles/bigquery.dataEditor"  = true
}

# General Configurations
project_id       = "spanner-gke-443910"
region           = "us-central1"
service_account  = "dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com"
