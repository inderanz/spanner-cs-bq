variable "project_id" {
  description = "GCP Project ID."
  type        = string
}

variable "dataset_id" {
  description = "BigQuery Dataset ID."
  type        = string
}

variable "access_roles" {
  description = "List of roles and their members."
  type = list(object({
    role    = string
    members = list(string)
  }))
}




