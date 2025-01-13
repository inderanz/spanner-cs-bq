variable "project_id" {
  description = "The GCP project ID where the Pub/Sub topic will be created."
  type        = string
}

variable "name" {
  description = "Name of the Pub/Sub topic."
  type        = string
}

variable "labels" {
  description = "Labels to apply to the Pub/Sub topic."
  type        = map(string)
  default     = {}
}

variable "kms_key" {
  description = "KMS key for encrypting the Pub/Sub topic."
  type        = string
  default     = null
}

variable "schema" {
  description = "Schema for the Pub/Sub topic."
  type        = string
  default     = null
}

variable "message_storage_policy" {
  description = "Storage policy for the Pub/Sub topic."
  type = object({
    allowed_persistence_regions = list(string)
  })
  default = null
}
