 % terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/google...
- Installing hashicorp/google v6.15.0...
- Installed hashicorp/google v6.15.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
ai-learningharshvardhan@harshvadhansAir spanner-db % terraform import google_spanner_instance.spanner_instance "projects/spanner-gke-443910/instances/sample-instance"

google_spanner_instance.spanner_instance: Importing from ID "projects/spanner-gke-443910/instances/sample-instance"...
google_spanner_instance.spanner_instance: Import prepared!
  Prepared google_spanner_instance for import
google_spanner_instance.spanner_instance: Refreshing state... [id=spanner-gke-443910/sample-instance]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

ai-learningharshvardhan@harshvadhansAir spanner-db % terraform import google_spanner_database.spanner_database "projects/spanner-gke-443910/instances/sample-instance/databases/audit-db"

Error: resource address "google_spanner_database.spanner_database" does not exist in the configuration.

Before importing this resource, please create its configuration in the root module. For example:

resource "google_spanner_database" "spanner_database" {
  # (resource arguments)
}

ai-learningharshvardhan@harshvadhansAir spanner-db % terraform import google_spanner_database.spanner_database "projects/spanner-gke-443910/instances/sample-instance/databases/audit-db"

google_spanner_database.spanner_database: Importing from ID "projects/spanner-gke-443910/instances/sample-instance/databases/audit-db"...
google_spanner_database.spanner_database: Import prepared!
  Prepared google_spanner_database for import
google_spanner_database.spanner_database: Refreshing state... [id=sample-instance/audit-db]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

ai-learningharshvardhan@harshvadhansAir spanner-db % terraform import google_spanner_instance_iam_policy.spanner_iam_policy "projects/spanner-gke-443910/instances/sample-instance"

Error: resource address "google_spanner_instance_iam_policy.spanner_iam_policy" does not exist in the configuration.

Before importing this resource, please create its configuration in the root module. For example:

resource "google_spanner_instance_iam_policy" "spanner_iam_policy" {
  # (resource arguments)
}

ai-learningharshvardhan@harshvadhansAir spanner-db % terraform import google_spanner_instance_iam_policy.spanner_iam_policy "projects/spanner-gke-443910/instances/sample-instance"

google_spanner_instance_iam_policy.spanner_iam_policy: Importing from ID "projects/spanner-gke-443910/instances/sample-instance"...
╷
│ Error: Invalid spanner id format, expecting {projectId}/{instanceId}
│ 
│ 
╵

ai-learningharshvardhan@harshvadhansAir spanner-db % terraform import google_spanner_instance_iam_policy.spanner_iam_policy "spanner-gke-443910/instances/sample-instance" 

google_spanner_instance_iam_policy.spanner_iam_policy: Importing from ID "spanner-gke-443910/instances/sample-instance"...
╷
│ Error: Invalid spanner id format, expecting {projectId}/{instanceId}
│ 
│ 
╵

ai-learningharshvardhan@harshvadhansAir spanner-db % terraform import google_spanner_instance_iam_policy.spanner_iam_policy "spanner-gke-443910/sample-instance" 

google_spanner_instance_iam_policy.spanner_iam_policy: Importing from ID "spanner-gke-443910/sample-instance"...
google_spanner_instance_iam_policy.spanner_iam_policy: Import prepared!
  Prepared google_spanner_instance_iam_policy for import
google_spanner_instance_iam_policy.spanner_iam_policy: Refreshing state... [id=spanner-gke-443910/sample-instance]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

ai-learningharshvardhan@harshvadhansAir spanner-db % terraform state show google_spanner_instance.spanner_instance

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
ai-learningharshvardhan@harshvadhansAir spanner-db % terraform state show google_spanner_database.spanner_database

# google_spanner_database.spanner_database:
resource "google_spanner_database" "spanner_database" {
    database_dialect         = "GOOGLE_STANDARD_SQL"
    deletion_protection      = true
    enable_drop_protection   = false
    id                       = "sample-instance/audit-db"
    instance                 = "sample-instance"
    name                     = "audit-db"
    project                  = "spanner-gke-443910"
    state                    = "READY"
    version_retention_period = "1h"
}
ai-learningharshvardhan@harshvadhansAir spanner-db % 

% terraform state show google_spanner_instance_iam_policy.spanner_iam_policy

# google_spanner_instance_iam_policy.spanner_iam_policy:
resource "google_spanner_instance_iam_policy" "spanner_iam_policy" {
    etag        = "BwYpZbaT+XA="
    id          = "spanner-gke-443910/sample-instance"
    instance    = "sample-instance"
    policy_data = jsonencode(
        {
            bindings = [
                {
                    members = [
                        "principal://iam.googleapis.com/projects/354449891279/locations/global/workloadIdentityPools/spanner-gke-443910.svc.id.goog/subject/app-ns/my-app-ksa",
                        "principal://iam.googleapis.com/projects/354449891279/locations/global/workloadIdentityPools/spanner-gke-443910.svc.id.goog/subject/app-ns/sa/payment-service-ksa",
                        "principal://iam.googleapis.com/projects/354449891279/locations/global/workloadIdentityPools/spanner-gke-443910.svc.id.goog/subject/ns/app-ns/sa/payment-service-ksa",
                        "principal://iam.googleapis.com/projects/354449891279/locations/global/workloadIdentityPools/spanner-gke-443910.svc.id.goog/subject/system:serviceaccount:app-ns:payment-service-ksa",
                    ]
                    role    = "roles/spanner.databaseUser"
                },
            ]
        }
    )
    project     = "spanner-gke-443910"
}
ai-learningharshvardhan@harshvadhansAir spanner-db % 
