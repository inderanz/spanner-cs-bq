variable "project_id" {
  description = "The GCP project ID for the Dataflow job."
  type        = string
}

variable "region" {
  description = "Region for the Dataflow job."
  type        = string
}

variable "job_name" {
  description = "Name of the Dataflow job."
  type        = string
}

variable "template_gcs_path" {
  description = "GCS path to the Dataflow template."
  type        = string
}

variable "parameters" {
  description = "Parameters for the Dataflow job, including Spanner and BigQuery settings."
  type        = map(string)
}

variable "service_account" {
  description = "Service account email for running the Dataflow job."
  type        = string
}

variable "network_name" {
  description = "Network name (shared VPC or single project)."
  type        = string
}

variable "subnetwork_name" {
  description = "Subnetwork name."
  type        = string
}

variable "temp_bucket_name" {
  description = "Temporary bucket for Dataflow jobs."
  type        = string
}

variable "labels" {
  description = "Labels to be applied to all resources."
  type        = map(string)
}

variable "iam_roles" {
  description = "IAM roles to be assigned to the service account."
  type        = map(bool)
  default     = {}
}

variable "additional_parameters" {
  description = "Additional parameters for the Dataflow job."
  type        = map(string)
  default     = {}
}

variable "temp_bucket_retention_days" {
  description = "Retention period (in days) for temporary bucket lifecycle."
  type        = number
  default     = 30
}
variable "network_project_id" {
  description = "The project ID of the VPC network. Defaults to the current project if not set."
  type        = string
  default     = null
}
