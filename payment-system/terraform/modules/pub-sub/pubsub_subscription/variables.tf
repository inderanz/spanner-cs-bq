variable "project_id" {
  description = "The project ID where resources will be created."
  type        = string
}

variable "topic_name" {
  description = "The name of the Pub/Sub topic."
  type        = string
}

variable "subscription_id" {
  description = "The ID of the Pub/Sub subscription."
  type        = string
}

variable "ack_deadline" {
  description = "The acknowledgment deadline for the subscription in seconds."
  type        = number
  default     = 10
}

variable "retain_acked_messages" {
  description = "Whether to retain acknowledged messages in the subscription."
  type        = bool
  default     = false
}

variable "message_retention_duration" {
  description = "The duration to retain messages in the subscription."
  type        = string
  default     = "604800s"  # 7 days
}

variable "labels" {
  description = "Labels to apply to the Pub/Sub subscription."
  type        = map(string)
  default     = {}
}

variable "push_config" {
  description = "Optional push configuration for the subscription."
  type = object({
    push_endpoint = string
    attributes    = map(string)
  })
  default = null
}

variable "expiration_policy" {
  description = "Optional expiration policy for the subscription."
  type = object({
    ttl = string
  })
  default = null
}

variable "retry_policy" {
  description = "Optional retry policy for the subscription."
  type = object({
    minimum_backoff = string
    maximum_backoff = string
  })
  default = null
}
