# **Design for Spanner to BigQuery Pipeline with Change Streams and Dataflow**

## **Objective**
Design a scalable, secure, and enterprise-grade architecture for streaming changes from Google Cloud Spanner to BigQuery using Change Streams and Dataflow, while adhering to least privilege principles for IAM roles and permissions.

---

## **Architectural Overview**

### **Components**
1. **Google Cloud Spanner (Audit-DB):**
   - Source database for audit logs.
   - Tracks changes in the `audit_logs` table using Change Streams.

2. **Google Cloud Dataflow:**
   - Processes data from Spanner Change Streams.
   - Transforms the data as needed and writes to BigQuery.

3. **Google BigQuery:**
   - Target data warehouse for audit logs.
   - Provides a centralized platform for analytics and querying.

4. **Terraform:**
   - Automates provisioning of Spanner, BigQuery, and Dataflow resources with consistent configurations.

---

## **Design Considerations**
1. **IAM and Least Privilege:**
   - Ensure that each component only has the permissions required to perform its specific tasks.
   - Avoid assigning broad roles like `roles/owner` or `roles/editor`.

2. **Workload Identity Federation:**
   - Link Kubernetes Service Accounts (KSA) and Google Service Accounts (GSA) to securely access GCP resources.

3. **Environment Isolation:**
   - Separate configurations for `dev`, `staging`, and `prod` environments.

4. **Monitoring and Logging:**
   - Use Cloud Monitoring and Logging for observability.

---

## **Detailed IAM Design**

### **1. Spanner (Audit-DB)**
#### **Role Assignment**
- **KSA (Application Services):**
  - Role: `roles/spanner.databaseUser`
  - Scope: Limited to the `audit-db` database.
  - Purpose: Allows application services to write data to the `audit_logs` table.

- **Dataflow GSA:**
  - Role: `roles/spanner.databaseReader`
  - Scope: Limited to the `audit-db` database.
  - Purpose: Allows Dataflow to read changes from Spanner Change Streams.

#### **Terraform Configuration**
```hcl
resource "google_project_iam_binding" "spanner_db_user" {
  project = var.project_id
  role    = "roles/spanner.databaseUser"
  members = [
    "serviceAccount:application-sa@${var.project_id}.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "spanner_db_reader" {
  project = var.project_id
  role    = "roles/spanner.databaseReader"
  members = [
    "serviceAccount:dataflow-sa@${var.project_id}.iam.gserviceaccount.com"
  ]
}
```

### **2. Dataflow**
#### **Role Assignment**
- **Dataflow GSA:**
  - Role: `roles/dataflow.worker`
  - Scope: Project-wide.
  - Purpose: Allows the Dataflow job to execute and interact with GCP services.

- **BigQuery Data Ingestion:**
  - Role: `roles/bigquery.dataEditor`
  - Scope: Limited to the `audit_service_dataset` dataset.
  - Purpose: Allows Dataflow to write transformed data into BigQuery.

#### **Terraform Configuration**
```hcl
resource "google_project_iam_binding" "dataflow_worker" {
  project = var.project_id
  role    = "roles/dataflow.worker"
  members = [
    "serviceAccount:dataflow-sa@${var.project_id}.iam.gserviceaccount.com"
  ]
}

resource "google_bigquery_dataset_iam_binding" "bigquery_data_ingestion" {
  dataset_id = google_bigquery_dataset.audit_service_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  members    = [
    "serviceAccount:dataflow-sa@${var.project_id}.iam.gserviceaccount.com"
  ]
}
```

### **3. BigQuery**
#### **Role Assignment**
- **Support Staff Group:**
  - Role: `roles/bigquery.dataViewer`
  - Scope: Limited to the `audit_service_dataset` dataset.
  - Purpose: Allows support staff to query and analyze data in BigQuery.

#### **Terraform Configuration**
```hcl
resource "google_bigquery_dataset_iam_binding" "bigquery_viewer" {
  dataset_id = google_bigquery_dataset.audit_service_dataset.dataset_id
  role       = "roles/bigquery.dataViewer"
  members    = [
    "group:support-staff@yourdomain.com"
  ]
}
```

---

## **Infrastructure Provisioning Workflow**

### **Step 1: Provision Spanner and Change Streams**
1. Create the `audit_logs` table in Spanner.
2. Enable a Change Stream for the `audit_logs` table.

**Terraform Example:**
```hcl
resource "google_spanner_instance" "audit_instance" {
  name = "audit-instance"
  config = "regional-us-central1"
}

resource "google_spanner_database" "audit_db" {
  instance  = google_spanner_instance.audit_instance.name
  name      = "audit-db"
}

resource "google_spanner_database_ddl" "audit_table" {
  database = google_spanner_database.audit_db.name
  ddl = [
    "CREATE TABLE audit_logs (PUID STRING(36) NOT NULL, Action STRING(100) NOT NULL, Timestamp TIMESTAMP NOT NULL, Status STRING(50), ServiceName STRING(100), Metadata JSON, RetryCount INT64, ErrorDetails STRING(500)) PRIMARY KEY (PUID)",
    "CREATE CHANGE STREAM AuditLogChangeStream FOR audit_logs"
  ]
}
```

### **Step 2: Deploy Dataflow Pipeline**
- Use Terraform to provision the Dataflow job.
- Pass the Spanner Change Stream and BigQuery dataset/table as parameters.

**Terraform Example:**
```hcl
resource "google_dataflow_job" "audit_stream_job" {
  name             = "audit-stream-job"
  template_gcs_path = "gs://dataflow-templates/spanner-to-bigquery"
  parameters = {
    instanceId  = google_spanner_instance.audit_instance.name
    databaseId  = google_spanner_database.audit_db.name
    outputTable = "${google_bigquery_dataset.audit_service_dataset.dataset_id}.audit_logs"
  }
}
```

### **Step 3: Provision BigQuery Dataset and Table**
- Define the dataset and table schema using Terraform.

**Terraform Example:**
```hcl
resource "google_bigquery_dataset" "audit_service_dataset" {
  dataset_id = "audit_service_dataset"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_table" "audit_logs_table" {
  dataset_id = google_bigquery_dataset.audit_service_dataset.dataset_id
  table_id   = "audit_logs"
  schema     = file("schemas/audit_logs_schema.json")
}
```

---

## **Monitoring and Observability**
1. **Cloud Monitoring**:
   - Monitor Dataflow job metrics (e.g., throughput, errors).
   - Track Spanner Change Stream performance.

2. **Cloud Logging**:
   - Enable logging for Spanner, Dataflow, and BigQuery.
   - Set up alerts for pipeline failures or anomalies.

---

## **Summary**
This design ensures:
- **Security**: Scoped IAM roles with least privilege for each component.
- **Scalability**: Dataflow handles real-time streaming and BigQuery scales for large datasets.
- **Auditing**: Comprehensive monitoring and logging for observability and troubleshooting.

Let me know if you need further details or implementation support!

