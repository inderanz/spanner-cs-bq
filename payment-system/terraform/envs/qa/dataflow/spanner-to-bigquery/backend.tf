terraform {
  backend "gcs" {
    bucket = "gs://terraform-spanner-bq/"
    prefix = "envs/dev/spanner-to-bq"
  }
}
