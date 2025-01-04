terraform {
  backend "gcs" {
    bucket = "gs://terraform-spanner-bq/"
    prefix = "envs/dev/bigquery/instance1"
  }
}
