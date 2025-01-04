module "bigquery" {
  source           = "../../../../modules/bigquery"
  project_id       = var.project_id
  region           = var.region
  dataset_id       = var.dataset_id
  dataset_labels   = var.dataset_labels
  access_roles     = var.access_roles
  table_definitions = var.table_definitions
}
