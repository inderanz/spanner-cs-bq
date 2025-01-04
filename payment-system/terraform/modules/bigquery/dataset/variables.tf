variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "dataset_id" {
  description = "The ID of the BigQuery dataset."
  type        = string
}

variable "region" {
  description = "The region for the dataset."
  type        = string
}

variable "dataset_labels" {
  description = "Labels for the dataset."
  type        = map(string)
  default     = {}
}
