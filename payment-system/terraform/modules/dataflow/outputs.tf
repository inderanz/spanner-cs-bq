output "dataflow_job_name" {
  description = "The name of the Dataflow job."
  value       = google_dataflow_flex_template_job.dataflow_flex_job.name
}

output "dataflow_job_id" {
  description = "The unique ID of the Dataflow job."
  value       = google_dataflow_flex_template_job.dataflow_flex_job.id
}

output "dataflow_job_state" {
  description = "The current state of the Dataflow job (e.g., RUNNING, DONE, FAILED)."
  value       = google_dataflow_flex_template_job.dataflow_flex_job.state
}

output "dataflow_job_project" {
  description = "The project ID where the Dataflow job is deployed."
  value       = google_dataflow_flex_template_job.dataflow_flex_job.project
}

output "dataflow_job_region" {
  description = "The region where the Dataflow job is running."
  value       = google_dataflow_flex_template_job.dataflow_flex_job.region
}

output "dataflow_job_labels" {
  description = "Labels applied to the Dataflow job."
  value       = google_dataflow_flex_template_job.dataflow_flex_job.labels
}

output "dataflow_job_network" {
  description = "Network used by the Dataflow job."
  value       = google_dataflow_flex_template_job.dataflow_flex_job.network
}

output "dataflow_job_subnetwork" {
  description = "Subnetwork used by the Dataflow job."
  value       = google_dataflow_flex_template_job.dataflow_flex_job.subnetwork
}
output "network_url" {
  value = var.network_name == "default" ? "global/networks/default" : "projects/${var.project_id}/global/networks/${var.network_name}"
}
