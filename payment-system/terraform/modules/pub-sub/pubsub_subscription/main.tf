resource "google_pubsub_subscription" "subscription" {
  name                        = var.subscription_id
  topic                       = var.topic_name
  project                     = var.project_id
  ack_deadline_seconds        = var.ack_deadline
  retain_acked_messages       = var.retain_acked_messages
  message_retention_duration  = var.message_retention_duration
  labels                      = var.labels

  dynamic "push_config" {
    for_each = var.push_config != null ? [var.push_config] : []
    content {
      push_endpoint = push_config.value.push_endpoint
      attributes    = push_config.value.attributes
    }
  }

  dynamic "expiration_policy" {
    for_each = var.expiration_policy != null ? [var.expiration_policy] : []
    content {
      ttl = expiration_policy.value.ttl
    }
  }

  dynamic "retry_policy" {
    for_each = var.retry_policy != null ? [var.retry_policy] : []
    content {
      minimum_backoff = retry_policy.value.minimum_backoff
      maximum_backoff = retry_policy.value.maximum_backoff
    }
  }
}
