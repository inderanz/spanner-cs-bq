variable "project_id" {
  description = "The GCP project ID where BigQuery resources will be created."
  type        = string
}

variable "region" {
  description = "The region for BigQuery resources."
  type        = string
}

variable "dataset_id" {
  description = "The BigQuery dataset ID."
  type        = string
}

variable "dataset_labels" {
  description = "Key-value map of labels for the dataset."
  type        = map(string)
  default     = {}
}

variable "access_roles" {
  description = "IAM roles and their members."
  type = list(object({
    role    = string
    members = list(string)
  }))
}


variable "table_definitions" {
  description = "List of table definitions with schema and configurations."
  type = list(object({
    table_id   = string
    schema     = string
    clustering = optional(list(string), [])
    partitioning = optional(object({
      type          = string
      field         = optional(string)
      expiration_ms = optional(number)
    }), null)
    labels = optional(map(string), {})
  }))
  default = []
}
