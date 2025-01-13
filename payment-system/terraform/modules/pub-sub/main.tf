module "pubsub_topics" {
  source      = "./modules/pubsub_topic"
  for_each    = { for topic in var.topics : topic.name => topic }
  name        = each.value.name
  project_id  = var.project_id
  labels      = each.value.labels
  kms_key     = each.value.kms_key
  schema      = each.value.schema
  region      = each.value.region
  message_storage_policy = each.value.message_storage_policy
}

module "pubsub_subscriptions" {
  source      = "./modules/pubsub_subscription"
  for_each    = { for sub in var.subscriptions : sub.name => sub }
  name                  = each.value.name
  topic                 = each.value.topic
  project_id            = var.project_id
  ack_deadline_seconds  = each.value.ack_deadline_seconds
  retain_acked_messages = each.value.retain_acked_messages
  message_retention_duration = each.value.message_retention_duration
  labels                = each.value.labels
  push_config           = each.value.push_config
  expiration_policy     = each.value.expiration_policy
  retry_policy          = each.value.retry_policy
}
