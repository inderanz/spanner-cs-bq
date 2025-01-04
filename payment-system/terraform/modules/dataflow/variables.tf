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
  description = "Parameters for the Dataflow job."
  type        = map(string)
}

variable "service_account" {
  description = "Service account email for running the Dataflow job."
  type        = string
}

variable "use_shared_vpc" {
  description = "Flag to determine if shared VPC is used."
  type        = bool
  default     = false
}

variable "network_name" {
  description = "Network name (shared VPC or single project)."
  type        = string
}

variable "network_project_id" {
  description = "Project ID of the shared VPC host project."
  type        = string
  default     = null
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
  description = "Labels for Dataflow resources."
  type        = map(string)
}
variable "iam_roles" {
  description = "IAM roles to be assigned to the service account"
  type        = map(bool)
  default     = {}
}
variable "spanner_instance_id" {
  description = "The Spanner instance ID."
  type        = string
}

variable "spanner_database" {
  description = "The Spanner database name."
  type        = string
}

variable "spanner_change_stream" {
  description = "The Spanner change stream name."
  type        = string
}

variable "bigquery_dataset" {
  description = "The BigQuery dataset name."
  type        = string
}

variable "bigquery_table_template" {
  description = "The BigQuery table template."
  type        = string
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

variable "template_specific_parameters" {
  description = "Template-specific parameters for the Dataflow job."
  type        = map(string)
  default     = {}
}
