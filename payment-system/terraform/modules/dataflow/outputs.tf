output "dataflow_job_name" {
  description = "The name of the Dataflow job."
  value       = google_dataflow_job.dataflow_job.name
}

output "dataflow_job_id" {
  description = "The unique ID of the Dataflow job."
  value       = google_dataflow_job.dataflow_job.id
}

output "dataflow_job_state" {
  description = "The current state of the Dataflow job (e.g., RUNNING, DONE, FAILED)."
  value       = google_dataflow_job.dataflow_job.state
}

output "dataflow_job_project" {
  description = "The project ID where the Dataflow job is deployed."
  value       = google_dataflow_job.dataflow_job.project
}

output "dataflow_job_region" {
  description = "The region where the Dataflow job is running."
  value       = google_dataflow_job.dataflow_job.region
}

output "dataflow_job_labels" {
  description = "Labels applied to the Dataflow job."
  value       = google_dataflow_job.dataflow_job.labels
}

output "dataflow_job_temp_bucket" {
  description = "Temporary GCS bucket used by the Dataflow job."
  value       = google_dataflow_job.dataflow_job.temp_gcs_location
}

output "dataflow_job_network" {
  description = "Network used by the Dataflow job."
  value       = google_dataflow_job.dataflow_job.network
}

output "dataflow_job_subnetwork" {
  description = "Subnetwork used by the Dataflow job."
  value       = google_dataflow_job.dataflow_job.subnetwork
}
