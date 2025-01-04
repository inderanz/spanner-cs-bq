variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "dataset_id" {
  description = "The ID of the BigQuery dataset."
  type        = string
}

variable "table_definitions" {
  description = "List of table definitions."
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
