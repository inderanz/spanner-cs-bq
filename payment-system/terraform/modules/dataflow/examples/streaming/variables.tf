variable "project_id" {
  description = "The GCP project ID for the streaming job"
  type        = string
  default     = "spanner-gke-443910"
}

variable "region" {
  description = "The region for the streaming job"
  type        = string
  default     = "us-central1"
}

variable "job_name" {
  description = "The name of the streaming job"
  type        = string
  default     = "spanner-to-bigquery-dev"
}

variable "template_gcs_path" {
  description = "GCS path for the Dataflow streaming template"
  type        = string
  default     = "gs://dataflow-templates/latest/Spanner_Change_Stream_to_BigQuery"
}

variable "parameters" {
  description = "Parameters for the streaming Dataflow job"
  type        = map(string)
  default = {
    spannerInstanceId    = "dev-spanner-instance"
    spannerDatabase      = "dev-database"
    spannerChangeStream  = "dev-change-stream"
    bigQueryDataset      = "dev-dataset"
    bigQueryTableTemplate = "dev-table-template"
  }
}

variable "service_account" {
  description = "Service account for the streaming Dataflow job"
  type        = string
  default     = "dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com"
}

variable "use_shared_vpc" {
  description = "Whether to use a shared VPC for the streaming job"
  type        = bool
  default     = false
}

variable "network_name" {
  description = "The network name for the streaming job"
  type        = string
  default     = "default"
}

variable "subnetwork_name" {
  description = "The subnetwork name for the streaming job"
  type        = string
  default     = "default-subnet"
}

variable "temp_bucket_name" {
  description = "The temporary bucket for the streaming job"
  type        = string
  default     = "dataflow-temp-dev"
}

variable "labels" {
  description = "Labels for the streaming Dataflow job"
  type        = map(string)
  default = {
    environment = "dev"
    pipeline    = "spanner-to-bigquery"
    team        = "data"
  }
}
