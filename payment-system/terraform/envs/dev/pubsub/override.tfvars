project_id = "spanner-gke-443910"

name       = "spanner-change-streams-topic"
labels = {
  environment = "dev"
  purpose     = "spanner-change-streams"
}

kms_key = null
schema  = null # Set schema to null if not required
message_storage_policy = {
  allowed_persistence_regions = ["us-central1"]
}
