# Job Configuration
job_name           = "spanner-to-pubsub"
template_gcs_path  = "gs://dataflow-templates/latest/flex/Spanner_Change_Streams_to_PubSub"
parameters = {
  spannerInstanceId          = "sample-instance"
  spannerDatabase            = "shared-db"
  spannerMetadataInstanceId  = "sample-instance"
  spannerMetadataDatabase    = "shared-db"
  spannerChangeStreamName    = "shared_audit_db_cs"
  pubsubTopic                = "spanner-change-streams-topic"
}

# Networking Configuration
network_name         = "custom-dataflow-network"
subnetwork_name      = "custom-dataflow-subnet"

# Storage Configuration
temp_bucket_name     = "dataflow-temp-spanner-pubsub-dev"

# Labels
labels = {
  environment = "dev"
  team        = "data"
  pipeline    = "spanner-to-pubsub"
}

# IAM Configuration
iam_roles = {
  "roles/spanner.databaseReader" = true
  "roles/pubsub.publisher"       = true
  "roles/dataflow.worker"        = true
}

# General Configurations
project_id       = "spanner-gke-443910"
region           = "us-central1"
service_account  = "dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com"
