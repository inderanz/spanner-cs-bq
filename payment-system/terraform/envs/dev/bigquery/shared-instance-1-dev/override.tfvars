project_id = "spanner-gke-443910"  # The GCP project ID for the dev environment
region     = "us-central1"         # The region where resources will be created

dataset_id = "audit_service_dataset"  # Dataset ID to reflect its purpose

dataset_labels = {                 # Key-value map of labels for the BigQuery dataset
  environment = "dev"
  team        = "service-support-squad"
}

access_roles = [
  {
    role    = "roles/bigquery.dataEditor"
    members = ["serviceAccount:dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com"]
  }
]


table_definitions = [              # Definitions of BigQuery tables
  {
    table_id = "audit_logs"
    schema   = "schemas/audit_logs_schema.json"
  }
]
