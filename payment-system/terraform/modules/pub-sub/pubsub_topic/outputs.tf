output "topic_id" {
  description = "ID of the Pub/Sub topic."
  value       = google_pubsub_topic.topic.id
}
