module "pubsub_subscription" {
  source          = "../../../modules/pub-sub/pubsub_subscription"
  project_id      = var.project_id
  topic_name      = var.topic_name
  subscription_id = var.subscription_id
  ack_deadline    = var.ack_deadline
  labels          = var.labels
  push_config     = var.push_config
}
