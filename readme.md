**Overall High Level Flow**

Data written to Spanner table 'payment_audit_trail'
   ↓
Change Stream captures data changes (insert, update, delete)
   ↓
Data streamed to Dataflow pipeline
   ↓
Dataflow processes and transforms data asynchronously
   ↓
Transformed data written to BigQuery table 'payment_audit_trail_bq'

Why we creating this?

Audit service capability for support staff, particularly for tracking and resolving payment issues. 

Approach:

Asynchronous Processing instead Synchronous or Batch Processing	

Approach	Advantages	Disadvantages
Asynchronous (Current)	- Scalable.
- Real-time updates.
- Centralized in BigQuery for analytics.	- Slight latency (not real-time).
Synchronous Logging in Spanner	- Immediate data availability.	- High write costs.
- Potential performance impact.
Batch Processing	- Simplified processing logic.	- Delayed updates.
- Not suitable for real-time support.

1. Asynchronous Processing for Scalability
Why?:
Payment systems often process large volumes of transactions.
Asynchronous pipelines using Change Streams and Dataflow allow near-real-time data streaming without impacting the performance of the primary database.
Benefit: Supports high throughput and scalability while ensuring the audit trail remains up-to-date.

2. Centralized Analytics in BigQuery
Why?:
BigQuery is optimized for querying large datasets with complex filtering, joining, and aggregation.
It supports SQL-like queries, enabling support staff to easily search for specific payments or patterns.
Benefit: Provides a single source of truth for audit data, simplifying customer support and incident resolution.

3. Captures Data Changes in Spanner
Why?:
Change Streams in Spanner allow you to capture insert, update, and delete operations.
This ensures the audit trail reflects the actual changes in the payment_audit_trail table.
Benefit: Ensures accuracy and consistency of the audit log, which is critical for troubleshooting.

4. Flexible Processing with Dataflow
Why?:
Dataflow can handle data enrichment, transformation, and custom processing logic.
For example, it can add metadata (e.g., timestamps, user IDs) or filter out irrelevant changes before writing to BigQuery.
Benefit: Makes the audit log more comprehensive and useful for debugging.

Enhancements for Audit Service Capability
1. Query Optimization for Support Staff
Create pre-built queries in BigQuery for common support scenarios, such as:
Search by payment ID or customer details.
Identify payments stuck in specific statuses (e.g., processing, failed).
Summarize transactions by time period, customer, or region.

2. Dashboard for Real-Time Monitoring
Build a support dashboard using a BI tool like Looker Studio or Tableau integrated with BigQuery:
Display real-time data about payments, their status, and any stuck transactions.
Provide drill-down capabilities to investigate specific payments.

3. Alerts for Payment Issues
Set up Cloud Monitoring alerts for anomalies:
High failure rates in transactions.
Payments stuck in the same status for too long.
Dataflow pipelines can also include dead-letter queues (DLQs) to handle processing errors.

4. Metadata for Better Searchability
Enrich the audit data with:
Customer identifiers: Enables searching by customer.
Transaction state transitions: Tracks the lifecycle of each payment.
Timestamps: Captures when changes occurred for better debugging.

5. Support Role Access Control
Implement fine-grained IAM roles for support staff to:
Query BigQuery tables without altering the underlying data.
Access only the specific datasets they are authorized to view.

6. Redundancy and Backup
Ensure the BigQuery table is regularly backed up for compliance and data recovery.
Use Cloud Storage or BigQuery snapshots for archival purposes.

Conclusion

This asynchronous pipeline using Spanner Change Streams, Dataflow, and BigQuery is a recommended enterprise solution for building an audit service. It provides:

Real-time visibility into payment data.
Scalability to handle large transaction volumes.
Flexibility for querying and monitoring.

Implementation Approach:

# **Implementation Approach for Payment Audit Service**

## **Objective**

To build an audit service capability for tracking payment records and resolving customer issues by synchronizing data from Google Cloud Spanner to BigQuery using Change Streams and Dataflow. The solution provides real-time visibility into payment data, enabling support staff to debug and assist customers efficiently.

---

## **Tools and Their Roles**

### **1. Google Cloud Spanner**

- **Purpose:**

  - Primary database to store payment records, including the `payment_audit_trail` table.
  - Serves as the source of truth for transactional data.

- **Why Spanner?**

  - **Scalability:** Supports high-throughput payment systems.
  - **Strong Consistency:** Ensures accuracy in data processing.
  - **Change Streams:** Captures real-time changes (insert, update, delete) efficiently.

### **2. Spanner Change Streams**

- **Purpose:**

  - Detects real-time changes in the `payment_audit_trail` table.
  - Feeds these changes asynchronously into the Dataflow pipeline.

- **Why Change Streams?**

  - **Granular Data Capture:** Captures row-level changes efficiently.
  - **Event-Driven:** Provides flexibility to process data incrementally.

### **3. Google Cloud Dataflow**

- **Purpose:**

  - Processes data changes captured by Spanner Change Streams.
  - Transforms and enriches the data before writing it to BigQuery.

- **Why Dataflow?**

  - **Streaming and Batch Processing:** Handles both real-time and historical data.
  - **Autoscaling:** Dynamically adjusts resources based on data volume.
  - **Fault Tolerance:** Ensures reliability through retries and dead-letter queues (DLQs).

### **4. Google BigQuery**

- **Purpose:**

  - Centralized analytics platform to store processed data from Dataflow.
  - Serves as the queryable database for support staff to debug and track payments.

- **Why BigQuery?**

  - **Optimized for Analytics:** Handles complex queries over large datasets efficiently.
  - **SQL Interface:** Provides familiar tools for support staff.
  - **Scalability:** Handles petabyte-scale data effortlessly.

### **5. Apache Airflow (Cloud Composer)**

- **Purpose:**

  - Orchestrates the workflow, ensuring tasks like BigQuery table creation and Dataflow job execution occur in the correct sequence.

- **Why Airflow?**

  - **Dependency Management:** Handles complex dependencies between tasks.
  - **Retry Mechanisms:** Ensures workflows recover from transient failures.
  - **Scalability:** Manages workflows at scale.

### **6. Terraform**

- **Purpose:**

  - Infrastructure as Code (IaC) tool to provision and manage all GCP resources, including Spanner, Dataflow, BigQuery, and Cloud Composer.

- **Why Terraform?**

  - **Reproducibility:** Ensures consistent environment setups across `dev`, `staging`, and `prod`.
  - **Modularity:** Enables reuse of infrastructure components.
  - **State Management:** Tracks resource changes to prevent configuration drift.

### **7. GitOps with ArgoCD**

- **Purpose:**

  - Synchronizes Airflow DAGs and configuration files from a Git repository to Cloud Composer.

- **Why ArgoCD?**

  - **Version Control:** Maintains a complete history of DAG changes.
  - **Automation:** Automatically applies updates to the runtime environment.
  - **Self-Healing:** Ensures the environment is always in sync with Git.

### **8. Cloud Build**

- **Purpose:**

  - CI/CD tool to automate Terraform deployments and trigger Airflow DAG synchronization.

- **Why Cloud Build?**

  - **Integration with GCP:** Works seamlessly with other Google Cloud services.
  - **Parallel Jobs:** Deploys infrastructure and DAGs efficiently.
  - **Scalability:** Handles large-scale pipelines with minimal setup.

---

## **Implementation Workflow**

### **1. Spanner Change Streams Setup**

- Use Liquibase to create and manage the `payment_audit_trail` table and associated Change Streams.
  - **Change Stream:** Tracks changes (insert, update, delete) in the `payment_audit_trail` table.

### **2. Dataflow Pipeline**

- Create a Dataflow pipeline to:
  - Consume changes from Spanner Change Streams.
  - Enrich and transform data.
  - Write the transformed data to a BigQuery table `payment_audit_trail_bq`.

### **3. BigQuery Setup**

- Use Terraform to create:
  - Dataset: `payment_audit`.
  - Table: `payment_audit_trail_bq` with a schema matching the enriched data.

### **4. Workflow Orchestration with Airflow**

- Define a DAG to:
  - Ensure the BigQuery table exists.
  - Trigger the Dataflow pipeline.

### **5. CI/CD Automation with Cloud Build**

- Automate:
  - Infrastructure provisioning using Terraform.
  - Airflow DAG synchronization with ArgoCD.

### **6. Monitoring and Logging**

- Enable Cloud Monitoring and Logging for:
  - Spanner Change Streams.
  - Dataflow pipeline execution.
  - BigQuery query performance.

---

## **Advantages of This Approach**

### **1. Scalability**

- Handles high data volumes in real-time with minimal performance impact on the source database.

### **2. Reliability**

- Fault-tolerant pipeline with retries and dead-letter queues ensures consistent data processing.

### **3. Queryable Audit Logs**

- BigQuery provides an intuitive interface for support staff to debug and track payments efficiently.

### **4. Modularity and Reusability**

- Terraform modules and GitOps practices ensure a modular and maintainable codebase.

### **5. Observability**

- Comprehensive monitoring and logging enable quick identification of issues and bottlenecks.

# Cloud Spanner to BigQuery Real-Time Sync

This README provides a comprehensive guide for setting up and managing a real-time data sync pipeline using the **Cloud Spanner change streams to BigQuery** Dataflow template. This template streams data changes from Cloud Spanner to BigQuery using Dataflow Runner V2.

---

## Overview

### Template Purpose
- Streams data change records from Cloud Spanner tables to BigQuery.
- Captures all watched columns and includes them in BigQuery table rows.
- Automatically creates BigQuery tables if not existing, provided schema alignment.
- Stores unprocessed records in a Dead Letter Queue (DLQ).

### Key Features
- Real-time sync for inserts, updates, and deletes.
- Metadata fields for tracking changes.
- Supports **Exactly Once** and **At Least Once** delivery modes.
- Configurable schema, performance, and security options.

---

## Key Considerations

### Data Flow
- **Data Ingestion**: Captures change streams from Spanner and writes to BigQuery.
- **BigQuery Table Schema**: Must align with watched Spanner columns, including metadata fields.
- **Streaming Behavior**:
  - Writes rows out of order compared to Spanner commit timestamps.
  - Unprocessed records go to DLQ for retry.

### Metadata Fields
Metadata fields provide additional context:
- `_metadata_spanner_mod_type`: Modification type (INSERT, UPDATE, DELETE).
- `_metadata_spanner_commit_timestamp`: Time of commit in Spanner.
- `_metadata_spanner_table_name`: Source table name.
- `_metadata_spanner_record_sequence`: Order of records in a transaction.
- `_metadata_big_query_commit_timestamp`: Time of insertion into BigQuery.

---

## Configuration Parameters

### Spanner Configuration
- **Spanner Instance ID**: The Spanner instance hosting the source table.
- **Spanner Database**: The database containing the change stream.
- **Change Stream Name**: Defines tables/columns to watch.

### BigQuery Configuration
- **Dataset**: BigQuery dataset for storing synced data.
- **Table Schema**: Align schema with Spanner watched columns and metadata fields.

### Streaming Modes
- **Exactly Once**: Ensures no duplicates or missing records.
- **At Least Once**: Allows duplicates, improving performance and cost-efficiency.

### Metadata Table for Change Streams
- **Metadata Instance/Database**: Maintains connector metadata and checkpoints.
- **Database Roles** (Optional): Assign appropriate roles for secure access.

---

## Deployment and Optimization

### Regional Deployment
- Deploy Dataflow jobs in the same region as:
  - Spanner instance.
  - BigQuery dataset.
  - Cloud Storage bucket for temp/staging files.

### Resource Allocation
- **Workers**: Define initial and maximum worker instances.
- **Autoscaling**: Enable for dynamic resource optimization.
- **Machine Types**: Choose suitable machine types (e.g., `n1-standard-4`).

### Dead Letter Queue (DLQ)
- **Path**: Cloud Storage path for storing failed records.
- **Retry Interval**: Configure intervals (default: 10 minutes).

### Disk Size and Logs
- Allocate sufficient disk space for each worker.
- Enable heap dumps for OutOfMemory (OOM) errors.

---

## Schema Changes
- Schema changes in Spanner require recreating the pipeline.
- Configure Spanner **version_retention_period** for stale reads.

---

## Security and Compliance
- Use a service account with appropriate roles for Spanner, BigQuery, and Dataflow.
- Choose between **Google-managed keys** or **Cloud KMS keys** for encryption.

---

## Network Configuration
- **Private IPs**: Use private IPs if data resides in a private VPC.
- **Subnetwork**: Configure if using a shared VPC.
- Enable **Private Google Access** for private IP communication.

---

## Monitoring and Logging
- **Log Level**: Set to `INFO` by default or adjust as needed.
- Use Cloud Monitoring for pipeline performance and error tracking.

---

## Performance Tuning
- Enable **Streaming Engine** for high-throughput scenarios.
- Use **BigQuery Write API** for low-latency writes.
- Configure Spanner **request priority** (`HIGH`, `MEDIUM`, `LOW`).

---

## Testing and Deployment
- **Dry Run**: Validate schema and configurations before deploying.
- **Starting Timestamp**: Define a specific start time for syncing historical changes.

---

## Troubleshooting

### Dead Letter Queue (DLQ)
- Investigate unprocessed records in the DLQ for issues like:
  - Schema mismatches.
  - Network errors.

### Heap Dumps
- Analyze heap dumps for memory-related failures.

---

## Additional Notes

### Best Practices
- Minimize latency and costs by ensuring all resources are co-located in the same region.
- Monitor pipeline regularly to handle errors promptly.

### Limitations
- Schema propagation from Spanner to BigQuery is not supported.
- Precision loss may occur for certain data types (e.g., TIMESTAMP, JSON).

---

## Payment System-Specific Considerations

### SLA and Real-Time Performance
- **Latency Requirement**: Ensure changes in Cloud Spanner reflect in BigQuery within **10 seconds**.
- **Pipeline Design**:
  - Use **Streaming Engine** for low-latency processing.
  - Optimize region placement for Dataflow, Spanner, and BigQuery to reduce network latency.
- **Monitoring**:
  - Set up real-time monitoring for pipeline latency with alerts for SLA breaches.

### Transaction Volume and Scalability
- **Throughput**: Design the pipeline to handle **500 transactions per second (TPS)**, with autoscaling enabled for spikes.
- **Worker Configuration**:
  - Use machine types like `n2-standard-4` for better performance.
  - Set thresholds for maximum outstanding bundles and workers to prevent bottlenecks.

### Real-Time Reporting and Replay
- **Payment State Management**:
  - Include a `payment_state` column in BigQuery to track transaction states (`initiated`, `processed`, `failed`).
  - Index `PUID` (Payment Unique ID) for quick lookup and replay.
- **Replay Mechanism**:
  - Design a replay service to fetch and reprocess payments based on their state and `PUID`.
- **Error Tracking**:
  - Log failed transactions and their state transitions in BigQuery.

### Handling Spikes and High Availability
- **Traffic Spikes**:
  - Autoscale pipeline resources dynamically to handle sudden spikes.
  - Use Spanner `HIGH` priority for critical queries during peak loads.
- **High Availability**:
  - Enable cross-region replication for disaster recovery.
  - Configure Dataflow checkpointing to resume seamlessly after failures.

### Security and Compliance
- **Data Masking**:
  - Mask sensitive fields (e.g., cardholder details) before storing in BigQuery.
- **Encryption**:
  - Use Cloud KMS keys for encrypting data in transit and at rest.
- **Access Control**:
  - Restrict access using IAM roles and enable VPC Service Controls.

### Validation and Data Quality
- **Validation**:
  - Periodically validate data consistency between Spanner and BigQuery using row counts or checksums.
- **DLQ Retention**:
  - Store DLQ records for at least 7 days for analysis and retries.
- **Deduplication**:
  - Deduplicate data in BigQuery based on `PUID` to ensure correctness.

### Real-Time Reporting Enhancements
- **Partitioning and Clustering**:
  - Partition tables by `_metadata_spanner_commit_timestamp`.
  - Cluster by `PUID` for optimized reporting queries.
- **Dashboards**:
  - Integrate with BI tools (e.g., Looker Studio) for real-time payment state visualization.

---

By addressing these additional considerations, this pipeline ensures a reliable, scalable, and compliant solution tailored for a real-time payment system. For further details, refer to [Dataflow documentation](https://cloud.google.com/dataflow).


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

