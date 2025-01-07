# google_spanner_instance.spanner_instance:
resource "google_spanner_instance" "spanner_instance" {
    config                       = "projects/spanner-gke-443910/instanceConfigs/regional-us-central1"
    default_backup_schedule_type = "AUTOMATIC"
    display_name                 = "gaming spanner instance"
    edition                      = "STANDARD"
    effective_labels             = {
        "env" = "spanner-game-demo"
    }
    force_destroy                = false
    id                           = "spanner-gke-443910/sample-instance"
    labels                       = {}
    name                         = "sample-instance"
    num_nodes                    = 0
    processing_units             = 100
    project                      = "spanner-gke-443910"
    state                        = "READY"
    terraform_labels             = {}
}
