module "bigquery_dataset" {
  source        = "./dataset"
  project_id    = var.project_id
  dataset_id    = var.dataset_id
  region        = var.region
  dataset_labels = var.dataset_labels
}

module "bigquery_table" {
  source          = "./table"
  project_id      = var.project_id
  dataset_id      = module.bigquery_dataset.dataset_id
  table_definitions = var.table_definitions
}

module "bigquery_access" {
  source      = "./access"
  project_id  = var.project_id
  dataset_id  = module.bigquery_dataset.dataset_id
  access_roles = var.access_roles
}
