resource "google_pubsub_subscription" "subscription" {
  name                        = var.name
  topic                       = var.topic
  project                     = var.project_id
  ack_deadline_seconds        = var.ack_deadline_seconds
  retain_acked_messages       = var.retain_acked_messages
  message_retention_duration  = var.message_retention_duration
  labels                      = var.labels
  push_config {
    push_endpoint = var.push_config.push_endpoint
    attributes    = var.push_config.attributes
  }
  expiration_policy {
    ttl = var.expiration_policy.ttl
  }
  retry_policy {
    minimum_backoff = var.retry_policy.minimum_backoff
    maximum_backoff = var.retry_policy.maximum_backoff
  }
}
