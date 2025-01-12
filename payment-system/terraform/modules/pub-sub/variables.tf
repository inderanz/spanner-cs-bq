variable "project_id" {
  description = "The ID of the project where resources will be created."
  type        = string
}

variable "topics" {
  description = "List of Pub/Sub topics to create."
  type = list(object({
    name       = string
    labels     = optional(map(string), {})
    kms_key    = optional(string)
    schema     = optional(string)
    region     = optional(string, "us-central1")
    message_storage_policy = optional(object({
      allowed_persistence_regions = list(string)
    }))
  }))
  default = []
}

variable "subscriptions" {
  description = "List of Pub/Sub subscriptions to create."
  type = list(object({
    name                  = string
    topic                 = string
    ack_deadline_seconds  = optional(number, 10)
    retain_acked_messages = optional(bool, false)
    message_retention_duration = optional(string, "604800s")
    labels                = optional(map(string), {})
    push_config = optional(object({
      push_endpoint = string
      attributes    = optional(map(string), {})
    }))
    expiration_policy = optional(object({
      ttl = optional(string)
    }))
    retry_policy = optional(object({
      minimum_backoff = string
      maximum_backoff = string
    }))
  }))
  default = []
}
