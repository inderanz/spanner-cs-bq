module "pubsub" {
  source      = "../../../modules/pub-sub/pubsub_topic" # Update path as needed
  project_id  = var.project_id
  name        = var.name
  labels      = var.labels
  kms_key     = var.kms_key
  schema      = var.schema
  message_storage_policy = var.message_storage_policy
}
