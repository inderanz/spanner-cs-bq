variable "project_id" {
  description = "The GCP project ID for the batch job"
  type        = string
  default     = "spanner-gke-443910"
}

variable "region" {
  description = "The region for the batch job"
  type        = string
  default     = "us-central1"
}

variable "job_name" {
  description = "The name of the batch job"
  type        = string
  default     = "batch-job-dev"
}

variable "template_gcs_path" {
  description = "GCS path for the Dataflow batch template"
  type        = string
  default     = "gs://dataflow-templates/latest/Word_Count"
}

variable "parameters" {
  description = "Parameters for the batch Dataflow job"
  type = map(string)
  default = {
    inputFile = "gs://dataflow-input-dev/input.txt"
    output    = "gs://dataflow-output-dev/output"
  }
}

variable "service_account" {
  description = "Service account for the batch Dataflow job"
  type        = string
  default     = "dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com"
}

variable "use_shared_vpc" {
  description = "Whether to use a shared VPC for the batch job"
  type        = bool
  default     = false
}

variable "network_name" {
  description = "The network name for the batch job"
  type        = string
  default     = "default"
}

variable "subnetwork_name" {
  description = "The subnetwork name for the batch job"
  type        = string
  default     = "default-subnet"
}

variable "temp_bucket_name" {
  description = "The temporary bucket for the batch job"
  type        = string
  default     = "dataflow-temp-dev"
}

variable "labels" {
  description = "Labels for the batch Dataflow job"
  type        = map(string)
  default = {
    environment = "dev"
    pipeline    = "batch-job"
    team        = "data"
  }
}
