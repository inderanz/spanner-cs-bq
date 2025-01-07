# IAM Configuration
resource "google_service_account_iam_member" "dataflow" {
  for_each           = var.iam_roles
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account}"
  role               = each.key
  member             = "serviceAccount:${var.service_account}"
}

data "google_compute_network" "vpc" {
  count   = var.network_name != "" ? 1 : 0
  name    = var.network_name
  project = var.network_project_id != null ? var.network_project_id : var.project_id
}

data "google_compute_subnetwork" "subnet" {
  count   = var.subnetwork_name != "" ? 1 : 0
  name    = var.subnetwork_name
  region  = var.region
  project = var.network_project_id != null ? var.network_project_id : var.project_id
}

# Storage Configuration
resource "google_storage_bucket" "dataflow_temp_2" {
  count    = var.temp_bucket_name != "" ? 1 : 0
  name     = var.temp_bucket_name
  location = var.region
  labels   = var.labels
  
  force_destroy = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.temp_bucket_retention_days
    }
  }
}

resource "google_dataflow_flex_template_job" "dataflow_flex_job" {
  provider              = google-beta
  name                  = var.job_name
  project               = var.project_id
  region                = var.region
  service_account_email = var.service_account

  # Corrected network URL
  network               = "projects/${var.project_id}/global/networks/${var.network_name}"
  subnetwork            = var.subnetwork_name != "" ? "regions/${var.region}/subnetworks/${var.subnetwork_name}" : null

  container_spec_gcs_path = var.template_gcs_path
  temp_location           = var.temp_bucket_name != "" ? "gs://${google_storage_bucket.dataflow_temp_2[0].name}/temp" : null
  parameters              = merge(var.parameters, var.additional_parameters)
  labels                  = var.labels
}
