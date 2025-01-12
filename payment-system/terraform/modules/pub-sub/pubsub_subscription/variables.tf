output "subscription_id" {
  description = "ID of the Pub/Sub subscription."
  value       = google_pubsub_subscription.subscription.id
}
