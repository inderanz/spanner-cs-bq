# IAM Configuration
resource "google_service_account_iam_member" "dataflow" {
  for_each           = var.iam_roles
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account}"
  role               = each.key
  member             = "serviceAccount:${var.service_account}"
}

# Networking Configuration
data "google_compute_network" "vpc" {
  count   = var.network_name != "" ? 1 : 0
  name    = var.network_name
  project = var.network_project_id
}

data "google_compute_subnetwork" "subnet" {
  count   = var.subnetwork_name != "" ? 1 : 0
  name    = var.subnetwork_name
  region  = var.region
  project = var.network_project_id
}

# Storage Configuration
resource "google_storage_bucket" "dataflow_temp" {
  count    = var.temp_bucket_name != "" ? 1 : 0
  name     = var.temp_bucket_name
  location = var.region
  labels   = var.labels

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.temp_bucket_retention_days
    }
  }
}

# Job Configuration
resource "google_dataflow_job" "dataflow_job" {
  name               = var.job_name
  template_gcs_path  = var.template_gcs_path
  project            = var.project_id
  region             = var.region
  service_account_email = var.service_account
  network            = length(data.google_compute_network.vpc) > 0 ? data.google_compute_network.vpc[0].id : null
  subnetwork         = length(data.google_compute_subnetwork.subnet) > 0 ? data.google_compute_subnetwork.subnet[0].id : null
  temp_gcs_location  = var.temp_bucket_name != "" ? "gs://${google_storage_bucket.dataflow_temp[0].name}/temp" : null

  # Merge template-specific and additional parameters
  parameters = merge(
    var.template_specific_parameters,
    var.additional_parameters
  )

  labels = var.labels
}
