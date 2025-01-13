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

variable "push_config" {
  description = "Optional push configuration for the subscription (leave null for pull mode)."
  type        = object({
    push_endpoint = string
    attributes    = map(string)
  })
  default = null
}

variable "labels" {
  description = "Labels to apply to the Pub/Sub subscription."
  type        = map(string)
  default     = {}
}
