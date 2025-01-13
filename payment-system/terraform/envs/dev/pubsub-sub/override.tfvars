project_id      = "spanner-gke-443910"
topic_name      = "spanner-change-streams-topic"
subscription_id = "spanner-change-streams-subscription"

ack_deadline = 20  # Increase for slower processing or higher throughput

labels = {
  environment = "dev"
  team        = "data"
}

retain_acked_messages      = false
message_retention_duration = "604800s"  # 7 days

# Uncomment if using push configuration
# push_config = {
#   push_endpoint = "https://your-endpoint.example.com"
#   attributes    = { key1 = "value1", key2 = "value2" }
# }

# Uncomment if using expiration policy
# expiration_policy = {
#   ttl = "86400s"  # 1 day
# }

# Uncomment if using retry policy
# retry_policy = {
#   minimum_backoff = "5s"
#   maximum_backoff = "10s"
# }
