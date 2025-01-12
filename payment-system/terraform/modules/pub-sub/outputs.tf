output "pubsub_topics" {
  description = "Details of created Pub/Sub topics."
  value = module.pubsub_topics
}

output "pubsub_subscriptions" {
  description = "Details of created Pub/Sub subscriptions."
  value = module.pubsub_subscriptions
}
