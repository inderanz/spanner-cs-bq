terraform {
  backend "gcs" {
    bucket = "gs://terraform-spanner-bq/"
    prefix = "envs/dev/pubsub-to-bq"
  }
}
