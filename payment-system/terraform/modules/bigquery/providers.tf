provider "google" {
  project = var.project_id
  region  = var.region

# Explicitly use the Cloud Build service account
  impersonate_service_account = "cloudbuild-cicd@spanner-gke-443910.iam.gserviceaccount.com"
}