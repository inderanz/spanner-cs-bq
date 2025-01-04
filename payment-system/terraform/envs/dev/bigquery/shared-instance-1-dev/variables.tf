variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region."
  type        = string
  default     = "us-central1"
}

variable "dataset_id" {
  description = "The BigQuery dataset ID for this instance."
  type        = string
}

variable "dataset_labels" {
  description = "Labels for the BigQuery dataset."
  type        = map(string)
  default     = {
    environment = "dev"
    instance    = "instance1"
  }
}

variable "access_roles" {
  description = "IAM roles and members for dataset access."
  type = list(object({
    role    = string
    members = list(string) # Change `member` to `members` as a list
  }))
}



variable "table_definitions" {
  description = "Definitions of BigQuery tables"
  type = list(object({
    table_id   = string
    schema     = string
    clustering = optional(list(string), [])
    partitioning = optional(object({
      type          = string
      field         = optional(string)
      expiration_ms = optional(number)
    }), null)
  }))
}
