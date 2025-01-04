variable "project_id" {
  description = "The project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The region where resources will be created."
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


variable "network_name" {
  description = "The name of the VPC network."
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork in the VPC."
  type        = string
}

variable "temp_bucket_name" {
  description = "The name of the temporary storage bucket for Dataflow."
  type        = string
}

variable "labels" {
  description = "Labels to be applied to all resources."
  type        = map(string)
}

variable "iam_roles" {
  description = "IAM roles to assign to the service account."
  type        = map(bool)
}

variable "service_account" {
  description = "Service account email for Dataflow."
  type        = string
}

variable "parameters" {
  description = "Parameters for the Dataflow job."
  type        = map(string)
}

variable "additional_parameters" {
  description = "Additional parameters for the Dataflow job."
  type        = map(string)
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

variable "temp_bucket_retention_days" {
  description = "Retention period (in days) for temporary bucket lifecycle."
  type        = number
  default     = 30
}
