variable "name" {
  description = "Name of the Pub/Sub topic."
  type        = string
}

variable "project_id" {
  description = "Project ID."
  type        = string
}

variable "labels" {
  description = "Labels for the Pub/Sub topic."
  type        = map(string)
  default     = {}
}

variable "kms_key" {
  description = "KMS key for the Pub/Sub topic."
  type        = string
  default     = null
}

variable "schema" {
  description = "Schema for the Pub/Sub topic. Leave null if no schema is required."
  type        = string
  default     = null
}


variable "message_storage_policy" {
  description = "Storage policy for the topic."
  type = object({
    allowed_persistence_regions = list(string)
  })
  default = null
}
