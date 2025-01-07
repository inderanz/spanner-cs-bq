
# Dataflow Job Overview - Spanner to BigQuery Pipeline

This document provides an overview of the Spanner-to-BigQuery Dataflow pipeline, detailing the dataset configuration, schema, Dataflow job details, and troubleshooting steps for issues in the pipeline.

## Dataset Details

- **Dataset ID**: `audit_service_dataset`
- **Project ID**: `spanner-gke-443910`
- **Location**: `us-central1`
- **Labels**:
  - `environment`: `dev`
  - `team`: `service-support-squad`
  
### IAM Access Roles
- **WRITER**: `dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com`
- **OWNER**: `cloudbuild-cicd@spanner-gke-443910.iam.gserviceaccount.com`

These roles ensure that Dataflow and Cloud Build have the necessary permissions to interact with the dataset.

## Tables

### `audit_logs` Table Schema

| Column Name   | Type          | Required |
| ------------- | ------------- | -------- |
| `PUID`        | STRING        | Yes      |
| `Action`      | STRING        | Yes      |
| `Timestamp`   | TIMESTAMP     | Yes      |
| `Status`      | STRING        | No       |
| `ServiceName` | STRING        | No       |
| `Metadata`    | JSON          | No       |
| `RetryCount`  | INT64         | No       |
| `ErrorDetails`| STRING        | No       |

### Spanner Change Stream Setup

- **Change Stream Name**: `audit_db_change_stream`
- **Associated Table**: `payment_audit_trail`
- **Change Stream Configuration**: 
  - Tracks specific columns and operations (INSERT, UPDATE, DELETE)
  - Not all columns are tracked (ALL = False)

## Dataflow Pipeline Details

### Dataflow Jobs

- **Job Name**: `spanner-to-bigquery`
- **Job Type**: `Streaming`
- **Region**: `us-central1`
- **State**: `Running`
- **Created**: `2025-01-05 00:51:47`
- **Pipeline**: `spanner-to-bigquery`
- **Dataflow Template Version**: `2024-10-01-00_rc00`
  
#### Job Logs and State

- The Dataflow job is currently in a `RUNNING` state.
- Logs indicate errors related to partition issues: "Initial partition not found in metadata table."

### Dataflow Logs Streaming

To stream the logs of the Dataflow job:

```bash
gcloud logging read "resource.type=dataflow_step AND resource.labels.job_id=2025-01-04_16_51_47-15423036885126082476" \
  --project=spanner-gke-443910 \
  --format="table(timestamp, textPayload)" --limit=50



Error Logs (Partition Issue)
To fetch only error logs:

gcloud logging read "resource.type=dataflow_step AND severity=ERROR AND resource.labels.job_id=2025-01-04_16_51_47-15423036885126082476" \
  --project=spanner-gke-443910 \
  --format="table(timestamp, textPayload)" --limit=50


Dataflow Job Description
To view detailed job information:

gcloud dataflow jobs describe 2025-01-04_16_51_47-15423036885126082476 \
  --region=us-central1 \
  --project=spanner-gke-443910


Partition Issues

The error logs and metadata table show partitions in various states (RUNNING, FINISHED), but no new partitions seem to be processed, leading to potential issues with Change Stream metadata consistency.

BigQuery Dataset
Dataset: audit_service_dataset
Table: audit_logs
Rows: 0 (No data was reflected in BigQuery despite successful insertions in Spanner.)


bq query --nouse_legacy_sql \
"SELECT * FROM \`spanner-gke-443910.audit_service_dataset.audit_logs\`
 ORDER BY Timestamp DESC
 LIMIT 10;"


Test Data Insert in payment_audit_trail Table

INSERT INTO payment_audit_trail (PUID, Action, Status, Timestamp, ServiceName) 
VALUES 
  ('test-puid', 'test-action', 'success', CURRENT_TIMESTAMP(), 'test-service');


This insert statement was executed successfully, but no corresponding data appeared in BigQuery.

Metadata Table Inspection
Query the metadata table to ensure that it has valid partitions:

Partition Data:
PartitionToken	ParentTokens	StartTimestamp	EndTimestamp	HeartbeatMillis	State	Watermark	CreatedAt	ScheduledAt	RunningAt	FinishedAt
Parent0	[]	2025-01-04T14:58:14.046Z	9999-12-31T23:59:59.999999998Z	2000	FINISHED	2025-01-04T14:58:14.046Z	2025-01-04T15:01:27.858079Z	2025-01-04T15:01:28.705699Z	2025-01-04T15:01:28.733404Z	2025-01-04T15:01:29.569276Z
8BAYEHAc4hvZAAAYLAUoNhdWRpdF9kYl9jaGFuZ2Vfc3RyZWFtAAGEgQCCgIMIw2QAAAAAAFeEBB2xwRSFZzBfMAAB-F_wYq4ki0H6qG_wYq4sqcy6mH_wYq4ki0H6rAZAEB__8	['Parent0']	2025-01-04T14:58:14.046Z	9999-12-31T23:59:59.999999998Z	2000	FINISHED	2025-01-04T15:00:04.236Z	2025-01-04T15:01:29.520431Z	2025-01-04T15:01:30.437889Z	2025-01-04T15:01:30.469048Z	2025-01-04T15:01:30.935081Z
8BAYEHAc4hvZAAAYLAUoNhdWRpdF9kYl9jaGFuZ2Vfc3RyZWFtAAGEgQCCgIMIw2QAAAAAAFiEBB2xwRSFZzBfMAAB-F_wYq4qZ5v7GG_wYq41HqismH_wYq4qZ5v7HAZAEB__8	['8BAYEHAc4hvZAAAYLAUoNhdWRpdF9kYl9jaGFuZ2Vfc3RyZWFtAAGEgQCCgIMIw2QAAAAAAFeEBB2xwRSFZzBfMAAB-F_wYq4ki0H6qG_wYq4sqcy6mH_wYq4ki0H6rAZAEB__8']	2025-01-04T15:00:04.236209Z	9999-12-31T23:59:59.999999998Z	2000	RUNNING	2025-01-04T15:07:18.358Z	2025-01-04T15:01:30.893887Z	2025-01-04T15:01:31.224797Z	2025-01-04T15:01:31.249263Z	2025-01-04T15:01:31.274452Z
8BAYEHAc4hvZAAAYLAUoNhdWRpdF9kYl9jaGFuZ2Vfc3RyZWFtAAGEgQCCgIMIw2QAAAAAAFmEBB2xwRSFZzBfMAAB-F_wYq4qZ5v7GG_wYq4yFrmGCH_wYq4qZ5v7HAZAEB__8	['8BAYEHAc4hvZAAAYLAUoNhdWRpdF9kYl9jaGFuZ2Vfc3RyZWFtAAGEgQCCgIMIw2QAAAAAAFeEBB2xwRSFZzBfMAAB-F_wYq4ki0H6qG_wYq4sqcy6mH_wYq4ki0H6rAZAEB__8']	2025-01-04T15:00:04.236209Z	9999-12-31T23:59:59.999999998Z	2000	RUNNING	2025-01-04T15:07:18.359Z	2025-01-04T15:01:30.914879Z	2025-01-04T15:01:31.224797Z	2025-01-04T15:01:31.274452Z	
8BAYEHAc4hvZAAAYLAUoNhdWRpdF9kYl9jaGFuZ2Vfc3RyZWFtAAGEgQYC-uhQAoKCgIMIw2QAAAAAAACEBFTnRD6FZzY0Ml8zMTI0ODY5AAH__4X_BiriAUjP-4b_Birit69UD4eAwGQBAf	['Parent0']	2025-01-04T14:58:14.046Z	9999-12-31T23:59:59.999999998Z	2000	FINISHED	2025-01-04T15:04:52.96Z	2025-01-04T15:01:29.546335Z	2025-01-04T15:01:30.437889Z	2025-01-04T15:01:30.499935Z	2025-01-04T15:04:53.442881Z
8BAYEHAc4hvZAAAYLAUoNhdWRpdF9kYl9jaGFuZ2Vfc3RyZWFtAAGEgQYC-uhQAoKCgIMIw2QAAAAAAACEBFTnRD6FZzY0Ml8zMTI0ODY5AAH__4X_Birit69UD4b_BirjQJtCaoeAwGQBAf	['8BAYEHAc4hvZAAAYLAUoNhdWRpdF9kYl9jaGFuZ2Vfc3RyZWFtAAGEgQYC-uhQAoKCgIMIw2QAAAAAAACEBFTnRD6FZzY0Ml8zMTI0ODY5AAH__4X_BiriAUjP-4b_Birit69UD4eAwGQBAf']	2025-01-04T15:04:52.960271Z	9999-12-31T23:59:59.999999998Z	2000	RUNNING	2025-01-04T15:07:18.387Z	2025-01-04T15:04:53.424447Z	2025-01-04T15:04:54.290173Z	2025-01-04T15:04:54.309936Z	

Resolution Steps

Check Change Stream Configuration: Ensure that the correct columns and operations are tracked.
Investigate Dataflow Job Configuration: Resolve partition issues in the Dataflow pipeline.
Confirm Metadata Table Partition Consistency: Ensure that partitions are properly initialized and processed.

Conclusion
The current issue revolves around the Change Stream partitioning mechanism, preventing data from being consumed and reflected in BigQuery. The Dataflow job is running, but issues with partitions in the metadata table hinder proper data flow. Further investigation into the Change Stream configuration and Dataflow job settings is required.

For more details or troubleshooting, refer to the logs and metadata inspection results provided above.

Additional Queries and Commands

Insert test data into the payment_audit_trail table to simulate a stream update:

gcloud spanner databases execute-sql audit-db \
  --instance=sample-instance \
  --project=spanner-gke-443910 \
  --sql="INSERT INTO payment_audit_trail (PUID, Action, Timestamp, Status, ServiceName, Metadata, RetryCount, ErrorDetails) 
  VALUES 
  ('123e4567-e89b-12d3-a456-426614174000', 'CREATE', '2025-01-05T12:00:00Z', 'SUCCESS', 'OrderService', JSON '{\"orderId\":12345,\"amount\":100.5}', 0, NULL),
  ('123e4567-e89b-12d3-a456-426614174001', 'UPDATE', '2025-01-05T12:05:00Z', 'FAILURE', 'PaymentService', JSON '{\"orderId\":12345,\"amount\":100.5}', 1, 'Insufficient balance'),
  ('123e4567-e89b-12d3-a456-426614174002', 'DELETE', '2025-01-05T12:10:00Z', 'SUCCESS', 'AdminService', JSON '{\"recordId\":67890}', 0, NULL);"

Verify if the Change Stream processes this update:

bq query --nouse_legacy_sql \
"SELECT * FROM \`spanner-gke-443910.audit_service_dataset.audit_logs\`
 ORDER BY Timestamp DESC
 LIMIT 10;"

Display BigQuery table information:

bq show spanner-gke-443910:audit_service_dataset.audit_logs

View Dataflow job status:

gcloud dataflow jobs list --region=us-central1

gcloud dataflow jobs describe 2025-01-04_19_37_19-13419870172193443123 \
  --region=us-central1 \
  --project=spanner-gke-443910


**Stream the logs in real-time:**

gcloud logging read "resource.type=dataflow_step AND resource.labels.job_id=2025-01-04_19_37_19-13419870172193443123" \
  --project=spanner-gke-443910 \
  --format="table(timestamp, textPayload)" --limit=50


Fetch only error logs:

gcloud logging read "resource.type=dataflow_step AND severity=ERROR AND resource.labels.job_id=2025-01-04_19_37_19-13419870172193443123" \
  --project=spanner-gke-443910 \
  --format="table(timestamp, textPayload)" --limit=50

Inspect worker logs:

gcloud logging read "resource.type=dataflow_step AND resource.labels.job_id=2025-01-04_19_37_19-13419870172193443123 AND logName:worker" \
  --project=spanner-gke-443910 \
  --format="table(timestamp, textPayload)" --limit=50


Dataflow Logs Example (Streamed in Real-Time)

% gcloud logging read "resource.type=dataflow_step AND resource.labels.job_id=2025-01-04_19_37_19-13419870172193443123" \
    --project=spanner-gke-443910 \
    --format="table(timestamp, textPayload)" \
    --limit=50

TIMESTAMP                    TEXT_PAYLOAD
2025-01-05T05:46:45.072Z
2025-01-05T05:46:43.912Z
2025-01-05T05:46:42.974Z
2025-01-05T05:46:42.194Z
2025-01-05T05:46:41.293Z
2025-01-05T05:46:40.071Z
2025-01-05T05:46:38.940Z
2025-01-05T05:46:37.922Z
2025-01-05T05:46:37.259Z
2025-01-05T05:46:36.132Z
2025-01-05T05:46:35.182Z
2025-01-05T05:46:34.110Z
2025-01-05T05:46:32.932Z
2025-01-05T05:46:32.098Z
2025-01-05T05:46:31.022Z
2025-01-05T05:46:29.951Z
2025-01-05T05:46:29.044Z
2025-01-05T05:46:28.385Z
2025-01-05T05:46:27.290Z
2025-01-05T05:46:26.077539Z
2025-01-05T05:46:26.015Z
2025-01-05T05:46:25.048Z
2025-01-05T05:46:24.189Z
2025-01-05T05:46:23.248Z
2025-01-05T05:46:22.018Z
2025-01-05T05:46:21.247Z
2025-01-05T05:46:19.909Z


**Dataflow Job Description**

% gcloud dataflow jobs describe 2025-01-04_16_51_47-15423036885126082476 \
    --region=us-central1 \
    --project=spanner-gke-443910

createTime: '2025-01-05T00:51:47.808277Z'
currentState: JOB_STATE_RUNNING
currentStateTime: '2025-01-05T00:54:02.302644Z'
environment:
  userAgent:
    container.base_repository: gcr.io/cloud-dataflow/v1beta3
    fnapi.container.version: 2.59.0
    fnapi.environment.major.version: '8'
    java.vendor: Eclipse Adoptium
    java.version: 11.0.20
    legacy.container.version: 2.59.0
    legacy.environment.major.version: '8'
    name: Apache Beam SDK for Java
    os.arch: amd64
    os.name: Linux
    os.version: 6.1.112+
    version: 2.59.0
  version:
    job_type: FNAPI_STREAMING
    major: '8'
id: 2025-01-04_16_51_47-15423036885126082476
jobMetadata:
  sdkVersion:
    sdkSupportStatus: STALE
    version: 2.59.0
    versionDisplayName: Apache Beam SDK for Java
labels:
  environment: dev
  goog-dataflow-provided-template-name: spanner_change_streams_to_bigquery
  goog-dataflow-provided-template-type: flex
  goog-dataflow-provided-template-version: 2024-10-01-00_rc00
  goog-terraform-provisioned: 'true'
  pipeline: spanner-to-bigquery
  team: data
location: us-central1
name: spanner-to-bigquery
projectId: spanner-gke-443910
runtimeUpdatableParams:
  maxNumWorkers: 100
  minNumWorkers: 1
  workerUtilizationHint: 0.8
satisfiesPzi: false
serviceResources:
  zones:
  - us-central1-f
stageStates:
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F188
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:53:48.614Z'
  executionStageName: Read from Spanner Change Streams/Wait.OnSignal/Wait/Map/ParMultiDo(Anonymous)/View-org.apache.beam.sdk.values.PCollectionViews$SimplePCollectionView.<init>:1931#8bf72308025c8f5f-view26
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F176
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:53:48.614Z'
  executionStageName: failure195
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F191
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F193
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F189
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F192
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F173
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F190
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F187
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F174
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:53:48.614Z'
  executionStageName: success194
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T00:53:48.614Z'
  executionStageName: Read from Spanner Change Streams/Wait.OnSignal/Wait/Map/ParMultiDo(Anonymous)/View-org.apache.beam.sdk.values.PCollectionViews$SimplePCollectionView.<init>:1931#8bf72308025c8f5f-view-out27
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F180
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F177
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F183
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F185
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F181
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:53:48.614Z'
  executionStageName: Read from Spanner Change Streams/Wait.OnSignal/Wait/Map/ParMultiDo(Anonymous)/View-org.apache.beam.sdk.values.PCollectionViews$SimplePCollectionView.<init>:1931#8bf72308025c8f5f-view-writer-out25
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F184
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F186
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F182
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F179
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F175
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T00:53:48.614Z'
  executionStageName: start196
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T00:54:09.508Z'
  executionStageName: F178
  executionStageState: JOB_STATE_RUNNING
startTime: '2025-01-05T00:51:47.808277Z'
type: JOB_TYPE_STREAMING




**BigQuery Table Schema and Metadata**

% bq show spanner-gke-443910:audit_service_dataset.audit_logs

Table spanner-gke-443910:audit_service_dataset.audit_logs

gcloud dataflow jobs list --region=us-central1

   Last modified                  Schema                 Total Rows   Total Bytes   Expiration   Time Partitioning   Clustered Fields   Total Logical Bytes   Total Physical Bytes   Labels  
 ----------------- ------------------------------------ ------------ ------------- ------------ ------------------- ------------------ --------------------- ---------------------- -------- 
  04 Jan 14:51:01   |- PUID: string (required)           0            0                                                                 0                     0                              
                    |- Action: string (required)                                                                                                                                             
                    |- Timestamp: timestamp (required)                                                                                                                                       
                    |- Status: string                                                                                                                                                        
                    |- ServiceName: string                                                                                                                                                   
                    |- Metadata: json                                                                                                                                                        
                    |- RetryCount: integer                                                                                                                                                   
                    |- ErrorDetails: string                                                                                                                                                  


BigQuery Row Count Query


% bq query --nouse_legacy_sql \
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.audit_logs\`"

+------------+
| total_rows |
+------------+
|          0 |
+------------+

Test Data Insert into BigQuery

% echo '{"PUID":"test-id","Action":"CREATE","Timestamp":"2025-01-05T12:00:00Z","Status":"SUCCESS","ServiceName":"TestService","Metadata":"{\"key\":\"value\"}","RetryCount":0,"ErrorDetails":null}' > payload.json

% bq insert spanner-gke-443910:audit_service_dataset.audit_logs payload.json


Query to Verify Data in BigQuery

% bq query --nouse_legacy_sql \
"SELECT * FROM \`spanner-gke-443910.audit_service_dataset.audit_logs\`
 ORDER BY Timestamp DESC
 LIMIT 10;"

+---------+--------+---------------------+---------+-------------+-----------------+------------+--------------+
|  PUID   | Action |      Timestamp      | Status  | ServiceName |    Metadata     | RetryCount | ErrorDetails |
+---------+--------+---------------------+---------+-------------+-----------------+------------+--------------+
| test-id | CREATE | 2025-01-05 12:00:00 | SUCCESS | TestService | {"key":"value"} |          0 | NULL         |
+---------+--------+---------------------+---------+-------------+-----------------+------------+--------------+































#$$$$$$$$$$$
###########

















###########

####

# Dataflow Job Overview - Spanner to BigQuery Pipeline

This document provides an overview of the Spanner-to-BigQuery Dataflow pipeline, detailing the dataset configuration, schema, Dataflow job details, and troubleshooting steps for issues in the pipeline.

## Dataset Details

- **Dataset ID**: `audit_service_dataset`
- **Project ID**: `spanner-gke-443910`
- **Location**: `us-central1`
- **Labels**:
  - `environment`: `dev`
  - `team`: `service-support-squad`
  
### IAM Access Roles
- **WRITER**: `dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com`
- **OWNER**: `cloudbuild-cicd@spanner-gke-443910.iam.gserviceaccount.com`

These roles ensure that Dataflow and Cloud Build have the necessary permissions to interact with the dataset.

## Tables

### `audit_logs` Table Schema

| Column Name   | Type          | Required |
| ------------- | ------------- | -------- |
| `PUID`        | STRING        | Yes      |
| `Action`      | STRING        | Yes      |
| `Timestamp`   | TIMESTAMP     | Yes      |
| `Status`      | STRING        | No       |
| `ServiceName` | STRING        | No       |
| `Metadata`    | JSON          | No       |
| `RetryCount`  | INT64         | No       |
| `ErrorDetails`| STRING        | No       |

### Spanner Change Stream Setup

- **Change Stream Name**: `audit_db_change_stream`
- **Associated Table**: `payment_audit_trail`
- **Change Stream Configuration**: 
  - Tracks specific columns and operations (INSERT, UPDATE, DELETE)
  - Not all columns are tracked (ALL = False)

## Dataflow Pipeline Details

### Dataflow Jobs

- **Job Name**: `spanner-to-bigquery`
- **Job Type**: `Streaming`
- **Region**: `us-central1`
- **State**: `Running`
- **Created**: `2025-01-05 00:51:47`
- **Pipeline**: `spanner-to-bigquery`
- **Dataflow Template Version**: `2024-10-01-00_rc00`
  
#### Job Logs and State

- The Dataflow job is currently in a `RUNNING` state.
- Logs indicate errors related to partition issues: "Initial partition not found in metadata table."

### Dataflow Logs Streaming

To stream the logs of the Dataflow job:

```bash
gcloud logging read "resource.type=dataflow_step AND resource.labels.job_id=2025-01-04_16_51_47-15423036885126082476" \
  --project=spanner-gke-443910 \
  --format="table(timestamp, textPayload)" --limit=50






###############
% bq show spanner-gke-443910:audit_service_dataset.audit_logs


Table spanner-gke-443910:audit_service_dataset.audit_logs

   Last modified                  Schema                 Total Rows   Total Bytes   Expiration   Time Partitioning   Clustered Fields   Total Logical Bytes   Total Physical Bytes   Labels  
 ----------------- ------------------------------------ ------------ ------------- ------------ ------------------- ------------------ --------------------- ---------------------- -------- 
  04 Jan 14:51:01   |- PUID: string (required)           0            0                                                                 0                     0                              
                    |- Action: string (required)                                                                                                                                             
                    |- Timestamp: timestamp (required)                                                                                                                                       
                    |- Status: string                                                                                                                                                        
                    |- ServiceName: string                                                                                                                                                   
                    |- Metadata: json                                                                                                                                                        
                    |- RetryCount: integer                                                                                                                                                   
                    |- ErrorDetails: string     


% gcloud dataflow jobs describe 2025-01-04_19_37_19-13419870172193443123 \
    --region=us-central1 \
    --format="yaml"

createTime: '2025-01-05T03:37:19.529323Z'
currentState: JOB_STATE_RUNNING
currentStateTime: '2025-01-05T05:40:26.856540Z'
environment:
  userAgent:
    container.base_repository: gcr.io/cloud-dataflow/v1beta3
    fnapi.container.version: 2.61.0
    fnapi.environment.major.version: '8'
    java.vendor: Eclipse Adoptium
    java.version: 11.0.20
    legacy.container.version: 2.61.0
    legacy.environment.major.version: '8'
    name: Apache Beam SDK for Java
    os.arch: amd64
    os.name: Linux
    os.version: 6.1.112+
    version: 2.61.0
  version:
    job_type: FNAPI_STREAMING
    major: '8'
id: 2025-01-04_19_37_19-13419870172193443123
jobMetadata:
  sdkVersion:
    sdkSupportStatus: SUPPORTED
    version: 2.61.0
    versionDisplayName: Apache Beam SDK for Java
labels:
  environment: dev
  goog-dataflow-provided-template-name: spanner_change_streams_to_bigquery
  goog-dataflow-provided-template-type: flex
  goog-dataflow-provided-template-version: 2024-12-03-00_rc00
  goog-terraform-provisioned: 'true'
  pipeline: spanner-to-bigquery
  team: data
location: us-central1
name: spanner-to-bigquery
projectId: spanner-gke-443910
runtimeUpdatableParams:
  maxNumWorkers: 100
  minNumWorkers: 1
  workerUtilizationHint: 0.8
satisfiesPzi: false
serviceResources:
  zones:
  - us-central1-c
stageStates:
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F192
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:39:54.119Z'
  executionStageName: failure195
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F189
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F173
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:39:54.119Z'
  executionStageName: Read from Spanner Change Streams/Wait.OnSignal/Wait/Map/ParMultiDo(Anonymous)/View-org.apache.beam.sdk.values.PCollectionViews$SimplePCollectionView.<init>:1931#8bf72308025c8f5f-view26
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F178
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:39:54.119Z'
  executionStageName: start196
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F179
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F183
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F175
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F187
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:39:54.119Z'
  executionStageName: Read from Spanner Change Streams/Wait.OnSignal/Wait/Map/ParMultiDo(Anonymous)/View-org.apache.beam.sdk.values.PCollectionViews$SimplePCollectionView.<init>:1931#8bf72308025c8f5f-view-writer-out25
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F190
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F180
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F185
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F174
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F181
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F186
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F193
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F177
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F188
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F176
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F184
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:39:54.119Z'
  executionStageName: Read from Spanner Change Streams/Wait.OnSignal/Wait/Map/ParMultiDo(Anonymous)/View-org.apache.beam.sdk.values.PCollectionViews$SimplePCollectionView.<init>:1931#8bf72308025c8f5f-view-out27
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F191
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:40:11.704Z'
  executionStageName: F182
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-05T03:39:54.119Z'
  executionStageName: success194
  executionStageState: JOB_STATE_PENDING
startTime: '2025-01-05T03:37:19.529323Z'
type: JOB_TYPE_STREAMING
harshvardhan@harshvadhansAir terraform % gcloud logging read "resource.type=dataflow_step AND resource.labels.job_id=2025-01-04_19_37_19-13419870172193443123" \
    --project=spanner-gke-443910 \
    --format="table(timestamp, textPayload)" \
    --limit=50

TIMESTAMP                    TEXT_PAYLOAD
2025-01-05T05:51:44.335Z
2025-01-05T05:51:44.309Z
2025-01-05T05:51:43.177Z
2025-01-05T05:51:42.076Z
2025-01-05T05:51:40.983Z
2025-01-05T05:51:40.377Z
2025-01-05T05:51:38.872Z
2025-01-05T05:51:38.119Z
2025-01-05T05:51:37.439Z
2025-01-05T05:51:35.926Z
2025-01-05T05:51:35.046Z
2025-01-05T05:51:34.623945Z
2025-01-05T05:51:34.134Z
2025-01-05T05:51:32.988Z
2025-01-05T05:51:32.227Z
2025-01-05T05:51:31.144Z
2025-01-05T05:51:30.036Z
2025-01-05T05:51:29.222Z
2025-01-05T05:51:28.057Z
2025-01-05T05:51:26.899Z
2025-01-05T05:51:26.360Z
2025-01-05T05:51:24.952Z
2025-01-05T05:51:23.877Z
2025-01-05T05:51:23.158Z
2025-01-05T05:51:22.472Z
2025-01-05T05:51:20.978Z
2025-01-05T05:51:20.417752Z
2025-01-05T05:51:19.983Z
2025-01-05T05:51:19.124Z
2025-01-05T05:51:17.954Z
2025-01-05T05:51:17.098Z
2025-01-05T05:51:15.925Z
2025-01-05T05:51:14.882Z
2025-01-05T05:51:14.443Z
2025-01-05T05:51:13.028Z
2025-01-05T05:51:12.152Z
2025-01-05T05:51:11.237Z
2025-01-05T05:51:10.116Z
2025-01-05T05:51:09.658192Z
2025-01-05T05:51:09.656782Z
2025-01-05T05:51:09.644128Z
2025-01-05T05:51:08.985Z
2025-01-05T05:51:08.017Z
2025-01-05T05:51:07.297Z
2025-01-05T05:51:06.133Z
2025-01-05T05:51:05.266Z
2025-01-05T05:51:04.100Z
2025-01-05T05:51:02.863Z
2025-01-05T05:51:02.265Z
2025-01-05T05:51:01.146Z
harshvardhan@harshvadhansAir terraform % gcloud logging read "resource.type=dataflow_step AND resource.labels.job_id=2025-01-04_19_37_19-13419870172193443123 AND textPayload:(\"BigQuery\")" \
    --project=spanner-gke-443910 \
    --format="table(timestamp, textPayload)" \
    --limit=50

TIMESTAMP                       TEXT_PAYLOAD
2025-01-05T03:39:52.671737811Z  Fusing consumer Failed Mod JSON During BigQuery Writes/Map/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/StreamingWrite/BatchedStreamingWrite.ViaBundleFinalization/ParMultiDo(BatchAndInsertElements)
2025-01-05T03:39:52.651761702Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/StreamingWrite/BatchedStreamingWrite.ViaBundleFinalization/ParMultiDo(BatchAndInsertElements) into Write To BigQuery/StreamingInserts/StreamingWriteTables/StripShardId/Map/ParMultiDo(Anonymous)
2025-01-05T03:39:52.628205683Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/StripShardId/Map/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/GlobalWindow/Window.Assign
2025-01-05T03:39:52.607680175Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/GlobalWindow/Window.Assign into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/RestoreMetadata/ParDo(Anonymous)/ParMultiDo(Anonymous)
2025-01-05T03:39:52.585993251Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/RestoreMetadata/ParDo(Anonymous)/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/ExpandIterable/ParMultiDo(Anonymous)
2025-01-05T03:39:52.571396566Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/ExpandIterable/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey/MergeBuckets
2025-01-05T03:39:52.549166172Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey/MergeBuckets into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey/ReadStream
2025-01-05T03:39:51.020100924Z  Fusing consumer Write To BigQuery/PrepareWrite/ParDo(Anonymous)/ParMultiDo(Anonymous) into Mod JSON To TableRow/ParMultiDo(FailsafeModJsonToTableRow)
2025-01-05T03:39:50.883478566Z  Unzipping flatten Merge-Source-And-DLQ-Mod-JSON-u131 for input Mod-JSON-To-TableRow-ParMultiDo-FailsafeModJsonToTableRow-.com.google.cloud.teleport.v2.templates.spannerchangestreamstobigquery.FailsafeModJsonToTableRowTransformer$FailsafeModJsonToTableRow$2.<init>:94#cdecdb7fa820db14-c127
2025-01-05T03:39:50.862886083Z  Fusing unzipped copy of Write To BigQuery/PrepareWrite/ParDo(Anonymous)/ParMultiDo(Anonymous), through flatten Merge Source And DLQ Mod JSON/Unzipped-1, into producer Mod JSON To TableRow/ParMultiDo(FailsafeModJsonToTableRow)
2025-01-05T03:39:50.841970592Z  Unzipping flatten Merge-Source-And-DLQ-Mod-JSON-u129 for input Mod-JSON-To-TableRow-ParMultiDo-FailsafeModJsonToTableRow-.com.google.cloud.teleport.v2.templates.spannerchangestreamstobigquery.FailsafeModJsonToTableRowTransformer$FailsafeModJsonToTableRow$1.<init>:90#ad6715144982c968-c126
2025-01-05T03:39:50.824041608Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey/WriteStream into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/ReifyOriginalMetadata/ParDo(Anonymous)/ParMultiDo(Anonymous)
2025-01-05T03:39:50.801486013Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/ReifyOriginalMetadata/ParDo(Anonymous)/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/SetIdentityWindow/Window.Assign
2025-01-05T03:39:50.778333018Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/SetIdentityWindow/Window.Assign into Write To BigQuery/StreamingInserts/StreamingWriteTables/TagWithUniqueIds/ParMultiDo(TagWithUniqueIds)
2025-01-05T03:39:50.753234555Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/TagWithUniqueIds/ParMultiDo(TagWithUniqueIds) into Write To BigQuery/StreamingInserts/StreamingWriteTables/ShardTableWrites/ParMultiDo(GenerateShardedTable)
2025-01-05T03:39:50.736471534Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/ShardTableWrites/ParMultiDo(GenerateShardedTable) into Write To BigQuery/StreamingInserts/CreateTables/ParDo(CreateTables)/ParMultiDo(CreateTables)
2025-01-05T03:39:50.719685724Z  Fusing consumer Write To BigQuery/StreamingInserts/CreateTables/ParDo(CreateTables)/ParMultiDo(CreateTables) into Write To BigQuery/PrepareWrite/ParDo(Anonymous)/ParMultiDo(Anonymous)
2025-01-05T03:39:50.611131555Z  Fusing unzipped copy of Write Failed Mod JSON To DLQ/Creating 1m Window/Window.Assign, through flatten Merge Failed Mod JSON From Transform And BigQuery/Unzipped-1, into producer Write Failed Mod JSON To DLQ/ParDo(Anonymous)/ParMultiDo(Anonymous)
2025-01-05T03:39:50.587933294Z  Unzipping flatten Merge-Failed-Mod-JSON-From-Transform-And-BigQuery-u116 for input Write-Failed-Mod-JSON-To-DLQ-ParDo-Anonymous--ParMultiDo-Anonymous-.output-c114
2025-01-05T03:39:50.520963766Z  Fusing unzipped copy of Write Failed Mod JSON To DLQ/ParDo(Anonymous)/ParMultiDo(Anonymous), through flatten Merge Failed Mod JSON From Transform And BigQuery, into producer Failed Mod JSON During BigQuery Writes/Map/ParMultiDo(Anonymous)
2025-01-05T03:39:50.499220359Z  Unzipping flatten Merge-Failed-Mod-JSON-From-Transform-And-BigQuery for input Failed-Mod-JSON-During-BigQuery-Writes-Map-ParMultiDo-Anonymous-.output
2025-01-05T03:39:49.503885192Z  Combiner lifting skipped for step Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey: GroupByKey not followed by a combiner.
harshvardhan@harshvadhansAir terraform % 



% gcloud logging read "resource.type=dataflow_step AND resource.labels.job_id=2025-01-04_19_37_19-13419870172193443123 AND textPayload:(\"BigQuery\")" \
    --project=spanner-gke-443910 \
    --format="table(timestamp, textPayload)" \
    --limit=50

TIMESTAMP                       TEXT_PAYLOAD
2025-01-05T03:39:52.671737811Z  Fusing consumer Failed Mod JSON During BigQuery Writes/Map/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/StreamingWrite/BatchedStreamingWrite.ViaBundleFinalization/ParMultiDo(BatchAndInsertElements)
2025-01-05T03:39:52.651761702Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/StreamingWrite/BatchedStreamingWrite.ViaBundleFinalization/ParMultiDo(BatchAndInsertElements) into Write To BigQuery/StreamingInserts/StreamingWriteTables/StripShardId/Map/ParMultiDo(Anonymous)
2025-01-05T03:39:52.628205683Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/StripShardId/Map/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/GlobalWindow/Window.Assign
2025-01-05T03:39:52.607680175Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/GlobalWindow/Window.Assign into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/RestoreMetadata/ParDo(Anonymous)/ParMultiDo(Anonymous)
2025-01-05T03:39:52.585993251Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/RestoreMetadata/ParDo(Anonymous)/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/ExpandIterable/ParMultiDo(Anonymous)
2025-01-05T03:39:52.571396566Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/ExpandIterable/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey/MergeBuckets
2025-01-05T03:39:52.549166172Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey/MergeBuckets into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey/ReadStream
2025-01-05T03:39:51.020100924Z  Fusing consumer Write To BigQuery/PrepareWrite/ParDo(Anonymous)/ParMultiDo(Anonymous) into Mod JSON To TableRow/ParMultiDo(FailsafeModJsonToTableRow)
2025-01-05T03:39:50.883478566Z  Unzipping flatten Merge-Source-And-DLQ-Mod-JSON-u131 for input Mod-JSON-To-TableRow-ParMultiDo-FailsafeModJsonToTableRow-.com.google.cloud.teleport.v2.templates.spannerchangestreamstobigquery.FailsafeModJsonToTableRowTransformer$FailsafeModJsonToTableRow$2.<init>:94#cdecdb7fa820db14-c127
2025-01-05T03:39:50.862886083Z  Fusing unzipped copy of Write To BigQuery/PrepareWrite/ParDo(Anonymous)/ParMultiDo(Anonymous), through flatten Merge Source And DLQ Mod JSON/Unzipped-1, into producer Mod JSON To TableRow/ParMultiDo(FailsafeModJsonToTableRow)
2025-01-05T03:39:50.841970592Z  Unzipping flatten Merge-Source-And-DLQ-Mod-JSON-u129 for input Mod-JSON-To-TableRow-ParMultiDo-FailsafeModJsonToTableRow-.com.google.cloud.teleport.v2.templates.spannerchangestreamstobigquery.FailsafeModJsonToTableRowTransformer$FailsafeModJsonToTableRow$1.<init>:90#ad6715144982c968-c126
2025-01-05T03:39:50.824041608Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey/WriteStream into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/ReifyOriginalMetadata/ParDo(Anonymous)/ParMultiDo(Anonymous)
2025-01-05T03:39:50.801486013Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/ReifyOriginalMetadata/ParDo(Anonymous)/ParMultiDo(Anonymous) into Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/SetIdentityWindow/Window.Assign
2025-01-05T03:39:50.778333018Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/SetIdentityWindow/Window.Assign into Write To BigQuery/StreamingInserts/StreamingWriteTables/TagWithUniqueIds/ParMultiDo(TagWithUniqueIds)
2025-01-05T03:39:50.753234555Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/TagWithUniqueIds/ParMultiDo(TagWithUniqueIds) into Write To BigQuery/StreamingInserts/StreamingWriteTables/ShardTableWrites/ParMultiDo(GenerateShardedTable)
2025-01-05T03:39:50.736471534Z  Fusing consumer Write To BigQuery/StreamingInserts/StreamingWriteTables/ShardTableWrites/ParMultiDo(GenerateShardedTable) into Write To BigQuery/StreamingInserts/CreateTables/ParDo(CreateTables)/ParMultiDo(CreateTables)
2025-01-05T03:39:50.719685724Z  Fusing consumer Write To BigQuery/StreamingInserts/CreateTables/ParDo(CreateTables)/ParMultiDo(CreateTables) into Write To BigQuery/PrepareWrite/ParDo(Anonymous)/ParMultiDo(Anonymous)
2025-01-05T03:39:50.611131555Z  Fusing unzipped copy of Write Failed Mod JSON To DLQ/Creating 1m Window/Window.Assign, through flatten Merge Failed Mod JSON From Transform And BigQuery/Unzipped-1, into producer Write Failed Mod JSON To DLQ/ParDo(Anonymous)/ParMultiDo(Anonymous)
2025-01-05T03:39:50.587933294Z  Unzipping flatten Merge-Failed-Mod-JSON-From-Transform-And-BigQuery-u116 for input Write-Failed-Mod-JSON-To-DLQ-ParDo-Anonymous--ParMultiDo-Anonymous-.output-c114
2025-01-05T03:39:50.520963766Z  Fusing unzipped copy of Write Failed Mod JSON To DLQ/ParDo(Anonymous)/ParMultiDo(Anonymous), through flatten Merge Failed Mod JSON From Transform And BigQuery, into producer Failed Mod JSON During BigQuery Writes/Map/ParMultiDo(Anonymous)
2025-01-05T03:39:50.499220359Z  Unzipping flatten Merge-Failed-Mod-JSON-From-Transform-And-BigQuery for input Failed-Mod-JSON-During-BigQuery-Writes-Map-ParMultiDo-Anonymous-.output
2025-01-05T03:39:49.503885192Z  Combiner lifting skipped for step Write To BigQuery/StreamingInserts/StreamingWriteTables/Reshuffle/GroupByKey: GroupByKey not followed by a combiner.
harshvardhan@harshvadhansAir terraform % bq show --schema --format=prettyjson spanner-gke-443910:audit_service_dataset.audit_logs

[
  {
    "mode": "REQUIRED",
    "name": "PUID",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "Action",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "Timestamp",
    "type": "TIMESTAMP"
  },
  {
    "mode": "NULLABLE",
    "name": "Status",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "ServiceName",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "Metadata",
    "type": "JSON"
  },
  {
    "mode": "NULLABLE",
    "name": "RetryCount",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "ErrorDetails",
    "type": "STRING"
  }
]
harshvardhan@harshvadhansAir terraform % bq show --format=prettyjson spanner-gke-443910:audit_service_dataset.audit_logs

{
  "creationTime": "1735962661854",
  "etag": "Kn3x0s4Hx8oSMV5T3fIq5A==",
  "id": "spanner-gke-443910:audit_service_dataset.audit_logs",
  "kind": "bigquery#table",
  "lastModifiedTime": "1735962661893",
  "location": "us-central1",
  "numActiveLogicalBytes": "0",
  "numActivePhysicalBytes": "0",
  "numBytes": "0",
  "numCurrentPhysicalBytes": "0",
  "numLongTermBytes": "0",
  "numLongTermLogicalBytes": "0",
  "numLongTermPhysicalBytes": "0",
  "numRows": "0",
  "numTimeTravelPhysicalBytes": "0",
  "numTotalLogicalBytes": "0",
  "numTotalPhysicalBytes": "0",
  "schema": {
    "fields": [
      {
        "mode": "REQUIRED",
        "name": "PUID",
        "type": "STRING"
      },
      {
        "mode": "REQUIRED",
        "name": "Action",
        "type": "STRING"
      },
      {
        "mode": "REQUIRED",
        "name": "Timestamp",
        "type": "TIMESTAMP"
      },
      {
        "mode": "NULLABLE",
        "name": "Status",
        "type": "STRING"
      },
      {
        "mode": "NULLABLE",
        "name": "ServiceName",
        "type": "STRING"
      },
      {
        "mode": "NULLABLE",
        "name": "Metadata",
        "type": "JSON"
      },
      {
        "mode": "NULLABLE",
        "name": "RetryCount",
        "type": "INTEGER"
      },
      {
        "mode": "NULLABLE",
        "name": "ErrorDetails",
        "type": "STRING"
      }
    ]
  },
  "selfLink": "https://bigquery.googleapis.com/bigquery/v2/projects/spanner-gke-443910/datasets/audit_service_dataset/tables/audit_logs",
  "streamingBuffer": {
    "estimatedBytes": "329",
    "estimatedRows": "1",
    "oldestEntryTime": "1736055744577"
  },
  "tableReference": {
    "datasetId": "audit_service_dataset",
    "projectId": "spanner-gke-443910",
    "tableId": "audit_logs"
  },
  "type": "TABLE"
}







$$$$$$$$$$$$$$$ < 938>

# DataFlow & Spanner Integration Documentation

## Use-Cases

### 1) Existing Step-up

**No Active Dataflow Job**

```bash
% gcloud dataflow jobs list --region=us-central1
JOB_ID                                    NAME                 TYPE       CREATION_TIME        STATE      REGION
2025-01-04_19_37_19-13419870172193443123  spanner-to-bigquery  Streaming  2025-01-05 03:37:19  Cancelled  us-central1
2025-01-04_06_56_44-73592908735007030     spanner-to-bigquery  Streaming  2025-01-04 14:56:45  Cancelled  us-central1
2025-01-04_18_13_58-1673212780683485169   spanner-to-bigquery  Streaming  2025-01-05 02:13:59  Cancelled  us-central1
2025-01-04_16_51_47-15423036885126082476  spanner-to-bigquery  Streaming  2025-01-05 00:51:47  Cancelled  us-central1


2) Existing DB & its Tables
A) List Databases in Spanner

% gcloud spanner databases list \
    --instance=sample-instance \
    --project=spanner-gke-443910

NAME             STATE  VERSION_RETENTION_PERIOD  EARLIEST_VERSION_TIME        KMS_KEY_NAME  ENABLE_DROP_PROTECTION
audit-db         READY  1h                        2025-01-06T23:43:15.955351Z
sample-audit-db  READY  1h                        2025-01-06T23:43:15.955354Z
sample-game      READY  1h                        2025-01-06T23:43:15.955355Z
shared-db        READY  1h                        2025-01-06T23:43:15.955356Z

B-0) List Tables in shared-db


% gcloud spanner databases execute-sql shared-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT table_name FROM information_schema.tables WHERE table_schema = '';"

table_name
payment_audit_trail
Payments
Reconciliation
Transactions

B-1) List Tables in audit-db

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT table_name FROM information_schema.tables WHERE table_schema = '';"

table_name
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6
payment_audit_trail

Where:
--instance: Specifies the Spanner instance name (sample-instance).
--project: Specifies the project ID (spanner-gke-443910).
--sql: Executes the SQL query to fetch the table names from the information_schema.tables where table_schema is empty.


3) Associated ChangeStream with the Database

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT change_stream_name FROM information_schema.change_streams;"

change_stream_name
audit_db_change_stream

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT * FROM information_schema.change_streams;"

CHANGE_STREAM_CATALOG  CHANGE_STREAM_SCHEMA  CHANGE_STREAM_NAME      ALL
                                             audit_db_change_stream  False



4) Verify Change Stream Target Table

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT table_name FROM information_schema.change_stream_tables WHERE change_stream_name = 'audit_db_change_stream';"

table_name
payment_audit_trail


5) List Schema Details for Each Table

A) Schema for audit-db

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="
        SELECT
            t.table_name,
            c.column_name,
            c.spanner_type,
            c.is_nullable
        FROM
            information_schema.tables AS t
        JOIN
            information_schema.columns AS c
        ON
            t.table_name = c.table_name
        WHERE
            t.table_schema = ''
        ORDER BY
            t.table_name, c.ordinal_position;"


Output:


Table Name	Column Name	Spanner Type	Is Nullable
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6	PartitionToken	STRING(MAX)	NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6	ParentTokens	ARRAY<STRING(MAX)>	NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6	StartTimestamp	TIMESTAMP	NO
...	...	...	...


B) Schema for shared-db


% gcloud spanner databases execute-sql shared-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="
        SELECT
            t.table_name,
            c.column_name,
            c.spanner_type,
            c.is_nullable
        FROM
            information_schema.tables AS t
        JOIN
            information_schema.columns AS c
        ON
            t.table_name = c.table_name
        WHERE
            t.table_schema = ''
        ORDER BY
            t.table_name, c.ordinal_position;"


6) Fetch and Display Metadata About the audit_logs Table


% bq show spanner-gke-443910:audit_service_dataset
Dataset spanner-gke-443910:audit_service_dataset

   Last modified                                ACLs                                          Labels              Type     Max time travel (Hours)  
 ----------------- --------------------------------------------------------------- ---------------------------- --------- ------------------------- 
  04 Jan 16:29:35   Owners:                                                         environment:dev              DEFAULT   168                      
                      cloudbuild-cicd@spanner-gke-443910.iam.gserviceaccount.com,   team:service-support-squad                                      
                      projectOwners                                                                                                                 


Adding Data and Managing Changes in BigQuery and Spanner

Insert Test Data into BigQuery


% echo '{"PUID":"test-id","Action":"CREATE","Timestamp":"2025-01-05T12:00:00Z","Status":"SUCCESS","ServiceName":"TestService","Metadata":"{\"key\":\"value\"}","RetryCount":0,"ErrorDetails":null}' > payload.json

% bq insert spanner-gke-443910:audit_service_dataset.audit_logs payload.json


Verify Data in BigQuery


% bq query --nouse_legacy_sql \
"SELECT * FROM \`spanner-gke-443910.audit_service_dataset.audit_logs\`
 ORDER BY Timestamp DESC
 LIMIT 10;"

+---------+--------+---------------------+---------+-------------+-----------------+------------+--------------+
|  PUID   | Action |      Timestamp      | Status  | ServiceName |    Metadata     | RetryCount | ErrorDetails |
+---------+--------+---------------------+---------+-------------+-----------------+------------+--------------+
| test-id | CREATE | 2025-01-05 12:00:00 | SUCCESS | TestService | {"key":"value"} |          0 | NULL         |
+---------+--------+---------------------+---------+-------------+-----------------+------------+--------------+




**Use-Cases**

1) Existing step-up

No Active dataflow job

% gcloud dataflow jobs list --region=us-central1
JOB_ID                                    NAME                 TYPE       CREATION_TIME        STATE      REGION
2025-01-04_19_37_19-13419870172193443123  spanner-to-bigquery  Streaming  2025-01-05 03:37:19  Cancelled  us-central1
2025-01-04_06_56_44-73592908735007030     spanner-to-bigquery  Streaming  2025-01-04 14:56:45  Cancelled  us-central1
2025-01-04_18_13_58-1673212780683485169   spanner-to-bigquery  Streaming  2025-01-05 02:13:59  Cancelled  us-central1
2025-01-04_16_51_47-15423036885126082476  spanner-to-bigquery  Streaming  2025-01-05 00:51:47  Cancelled  us-central1


2) Existing DB & its tables

A) % gcloud spanner databases list \
    --instance=sample-instance \
    --project=spanner-gke-443910

NAME             STATE  VERSION_RETENTION_PERIOD  EARLIEST_VERSION_TIME        KMS_KEY_NAME  ENABLE_DROP_PROTECTION
audit-db         READY  1h                        2025-01-06T23:43:15.955351Z
sample-audit-db  READY  1h                        2025-01-06T23:43:15.955354Z
sample-game      READY  1h                        2025-01-06T23:43:15.955355Z
shared-db        READY  1h                        2025-01-06T23:43:15.955356Z


B-0) % gcloud spanner databases execute-sql shared-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT table_name FROM information_schema.tables WHERE table_schema = '';"

table_name
payment_audit_trail
Payments
Reconciliation
Transactions

B-1) % gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT table_name FROM information_schema.tables WHERE table_schema = '';"

table_name
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6
payment_audit_trail

Where,
--instance: Specifies the Spanner instance name (sample-instance in this case).
--project: Specifies the project ID (spanner-gke-443910 in this case).
--sql: Executes the SQL query to fetch the table names from the information_schema.tables where the table_schema is empty (indicating user-defined tables).

3) Associated ChangeStream with the Database

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT change_stream_name FROM information_schema.change_streams;"
change_stream_name
audit_db_change_stream

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT * FROM information_schema.change_streams;"
CHANGE_STREAM_CATALOG  CHANGE_STREAM_SCHEMA  CHANGE_STREAM_NAME      ALL
                                             audit_db_change_stream  False

4)  Verify Change Stream Target Table: Check if the change stream is associated with the correct table(s):

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT table_name FROM information_schema.change_stream_tables WHERE change_stream_name = 'audit_db_change_stream';"
table_name
payment_audit_trail

5) list schema details (such as columns, data types, and constraints) for each table, you can query the information_schema views.

A)% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="
        SELECT
            t.table_name,
            c.column_name,
            c.spanner_type,
            c.is_nullable
        FROM
            information_schema.tables AS t
        JOIN
            information_schema.columns AS c
        ON
            t.table_name = c.table_name
        WHERE
            t.table_schema = ''
        ORDER BY
            t.table_name, c.ordinal_position;"

table_name                                              column_name      spanner_type        is_nullable
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  PartitionToken   STRING(MAX)         NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  ParentTokens     ARRAY<STRING(MAX)>  NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  StartTimestamp   TIMESTAMP           NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  EndTimestamp     TIMESTAMP           NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  HeartbeatMillis  INT64               NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  State            STRING(MAX)         NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  Watermark        TIMESTAMP           NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  CreatedAt        TIMESTAMP           NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  ScheduledAt      TIMESTAMP           YES
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  RunningAt        TIMESTAMP           YES
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  FinishedAt       TIMESTAMP           YES
payment_audit_trail                                     PUID             STRING(36)          NO
payment_audit_trail                                     Action           STRING(100)         NO
payment_audit_trail                                     Status           STRING(50)          YES
payment_audit_trail                                     Timestamp        TIMESTAMP           NO
payment_audit_trail                                     ServiceName      STRING(100)         YES
payment_audit_trail                                     Metadata         JSON                YES
payment_audit_trail                                     RetryCount       INT64               YES
payment_audit_trail                                     ErrorDetails     STRING(500)         YES

B) % gcloud spanner databases execute-sql shared-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="
        SELECT
            t.table_name,
            c.column_name,
            c.spanner_type,
            c.is_nullable
        FROM
            information_schema.tables AS t
        JOIN
            information_schema.columns AS c
        ON
            t.table_name = c.table_name
        WHERE
            t.table_schema = ''
        ORDER BY
            t.table_name, c.ordinal_position;"

table_name           column_name  spanner_type  is_nullable
Payments             PaymentUID   STRING(36)    NO
Payments             UserId       STRING(100)   YES
Payments             Amount       FLOAT64       YES
Payments             Status       STRING(50)    YES
Payments             Timestamp    TIMESTAMP     YES
Reconciliation       PUID         STRING(36)    NO
Reconciliation       Amount       FLOAT64       YES
Reconciliation       Status       STRING(50)    YES
Reconciliation       Timestamp    TIMESTAMP     YES
Transactions         PUID         STRING(36)    NO
Transactions         UserId       STRING(100)   YES
Transactions         Amount       FLOAT64       YES
Transactions         Status       STRING(50)    YES
Transactions         Timestamp    TIMESTAMP     YES
payment_audit_trail  PUID         STRING(36)    NO
payment_audit_trail  Action       STRING(100)   YES
payment_audit_trail  Status       STRING(50)    YES
payment_audit_trail  Timestamp    TIMESTAMP     YES



6) fetches and displays metadata about the audit_logs table in the audit_service_dataset dataset, providing insights into its schema, size, and other properties.


% bq show spanner-gke-443910:audit_service_dataset
Dataset spanner-gke-443910:audit_service_dataset

   Last modified                                ACLs                                          Labels              Type     Max time travel (Hours)  
 ----------------- --------------------------------------------------------------- ---------------------------- --------- ------------------------- 
  04 Jan 16:29:35   Owners:                                                         environment:dev              DEFAULT   168                      
                      cloudbuild-cicd@spanner-gke-443910.iam.gserviceaccount.com,   team:service-support-squad                                      
                      projectOwners                                                                                                                 
                    Writers:                                                                                                                        
                      dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com,                                                                       
                      projectWriters                                                                                                                
                    Readers:                                                                                                                        
                      projectReaders                                                                                                                

ai-learningharshvardhan@harshvadhansAir spanner-db % bq ls --project_id=spanner-gke-443910

        datasetId        
 ----------------------- 
  audit_service_dataset  



  % bq ls --dataset_id=spanner-gke-443910:audit_service_dataset

             tableId              Type    Labels   Time Partitioning   Clustered Fields  
 ------------------------------- ------- -------- ------------------- ------------------ 
  audit_logs                      TABLE                                                  
  audit_logs_dlq                  TABLE                                                  
  payment_audit_trail_changelog   TABLE              



 %  bq show spanner-gke-443910:audit_service_dataset.audit_logs
Table spanner-gke-443910:audit_service_dataset.audit_logs

   Last modified                  Schema                 Total Rows   Total Bytes   Expiration   Time Partitioning   Clustered Fields   Total Logical Bytes   Total Physical Bytes   Labels  
 ----------------- ------------------------------------ ------------ ------------- ------------ ------------------- ------------------ --------------------- ---------------------- -------- 
  05 Jan 17:43:27   |- PUID: string (required)           1            62                                                                62                    2596                           
                    |- Action: string (required)                                                                                                                                             
                    |- Timestamp: timestamp (required)                                                                                                                                       
                    |- Status: string                                                                                                                                                        
                    |- ServiceName: string                                                                                                                                                   
                    |- Metadata: json                                                                                                                                                        
                    |- RetryCount: integer                                                                                                                                                   
                    |- ErrorDetails: string  


% bq show spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog
Table spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog

   Last modified                                          Schema                                          Total Rows   Total Bytes   Expiration   Time Partitioning   Clustered Fields   Total Logical Bytes   Total Physical Bytes   Labels  
 ----------------- ------------------------------------------------------------------------------------- ------------ ------------- ------------ ------------------- ------------------ --------------------- ---------------------- -------- 
  05 Jan 21:07:48   |- PUID: string                                                                       90794        18199383                                                          18199383              2445496                        
                    |- Action: string                                                                                                                                                                                                         
                    |- Timestamp: timestamp                                                                                                                                                                                                   
                    |- Status: string                                                                                                                                                                                                         
                    |- ServiceName: string                                                                                                                                                                                                    
                    |- Metadata: json                                                                                                                                                                                                         
                    |- RetryCount: integer                                                                                                                                                                                                    
                    |- ErrorDetails: string                                                                                                                                                                                                   
                    |- _metadata_spanner_mod_type: string (required)                                                                                                                                                                          
                    |- _metadata_spanner_table_name: string (required)                                                                                                                                                                        
                    |- _metadata_spanner_commit_timestamp: timestamp (required)                                                                                                                                                               
                    |- _metadata_spanner_server_transaction_id: string (required)                                                                                                                                                             
                    |- _metadata_spanner_record_sequence: string (required)                                                                                                                                                                   
                    |- _metadata_spanner_is_last_record_in_transaction_in_partition: boolean (required)                                                                                                                                       
                    |- _metadata_spanner_number_of_records_in_transaction: integer (required)                                                                                                                                                 
                    |- _metadata_spanner_number_of_partitions_in_transaction: integer (required)                                                                                                                                              
                    |- _metadata_big_query_commit_timestamp: timestamp (required)     




bq: Refers to the BigQuery CLI tool, which is used to interact with Google BigQuery.
show: This sub-command displays metadata and schema details of a specific dataset, table, or view in BigQuery.
spanner-gke-443910:audit_service_dataset.audit_logs: Refers to the fully qualified identifier for the BigQuery table:
spanner-gke-443910: The Google Cloud project where the dataset resides.
audit_service_dataset: The dataset name within the project.
audit_logs: The specific table within the dataset whose metadata is being queried.


######

Schema for table: audit_logs
[
  {
    "mode": "REQUIRED",
    "name": "PUID",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "Action",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "Timestamp",
    "type": "TIMESTAMP"
  },
  {
    "mode": "NULLABLE",
    "name": "Status",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "ServiceName",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "Metadata",
    "type": "JSON"
  },
  {
    "mode": "NULLABLE",
    "name": "RetryCount",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "ErrorDetails",
    "type": "STRING"
  }
]
--------------------------------------------
Schema for table: audit_logs_dlq
[
  {
    "name": "PUID",
    "type": "STRING"
  },
  {
    "name": "Action",
    "type": "STRING"
  },
  {
    "name": "Timestamp",
    "type": "TIMESTAMP"
  },
  {
    "name": "Status",
    "type": "STRING"
  },
  {
    "name": "ServiceName",
    "type": "STRING"
  },
  {
    "name": "Metadata",
    "type": "JSON"
  },
  {
    "name": "RetryCount",
    "type": "INTEGER"
  },
  {
    "name": "ErrorDetails",
    "type": "STRING"
  }
]
--------------------------------------------
Schema for table: payment_audit_trail_changelog
[
  {
    "mode": "NULLABLE",
    "name": "PUID",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "Action",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "Timestamp",
    "type": "TIMESTAMP"
  },
  {
    "mode": "NULLABLE",
    "name": "Status",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "ServiceName",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "Metadata",
    "type": "JSON"
  },
  {
    "mode": "NULLABLE",
    "name": "RetryCount",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "ErrorDetails",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "_metadata_spanner_mod_type",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "_metadata_spanner_table_name",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "_metadata_spanner_commit_timestamp",
    "type": "TIMESTAMP"
  },
  {
    "mode": "REQUIRED",
    "name": "_metadata_spanner_server_transaction_id",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "_metadata_spanner_record_sequence",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "_metadata_spanner_is_last_record_in_transaction_in_partition",
    "type": "BOOLEAN"
  },
  {
    "mode": "REQUIRED",
    "name": "_metadata_spanner_number_of_records_in_transaction",
    "type": "INTEGER"
  },
  {
    "mode": "REQUIRED",
    "name": "_metadata_spanner_number_of_partitions_in_transaction",
    "type": "INTEGER"
  },
  {
    "mode": "REQUIRED",
    "name": "_metadata_big_query_commit_timestamp",
    "type": "TIMESTAMP"
  }
]


#######

Lets check on below usecases:

1) Provision / Start the dataflow job:


Terraform will perform the following actions:

  # module.dataflow.google_dataflow_flex_template_job.dataflow_flex_job will be created
  + resource "google_dataflow_flex_template_job" "dataflow_flex_job" {
      + additional_experiments       = (known after apply)
      + autoscaling_algorithm        = (known after apply)
      + container_spec_gcs_path      = "gs://dataflow-templates-us-central1/2024-12-03-00_RC00/flex/Spanner_Change_Streams_to_BigQuery"
      + effective_labels             = {
          + "environment"                = "dev"
          + "goog-terraform-provisioned" = "true"
          + "pipeline"                   = "spanner-to-bigquery"
          + "team"                       = "data"
        }
      + id                           = (known after apply)
      + job_id                       = (known after apply)
      + kms_key_name                 = (known after apply)
      + labels                       = {
          + "environment" = "dev"
          + "pipeline"    = "spanner-to-bigquery"
          + "team"        = "data"
        }
      + launcher_machine_type        = (known after apply)
      + machine_type                 = (known after apply)
      + max_workers                  = (known after apply)
      + name                         = "spanner-to-bigquery"
      + network                      = "projects/spanner-gke-443910/global/networks/custom-dataflow-network"
      + num_workers                  = (known after apply)
      + on_delete                    = "cancel"
      + parameters                   = {
          + "bigQueryChangelogTableNameTemplate" = "{_metadata_spanner_table_name}_changelog"
          + "bigQueryDataset"                    = "audit_service_dataset"
          + "spannerChangeStreamName"            = "audit_db_change_stream"
          + "spannerDatabase"                    = "audit-db"
          + "spannerInstanceId"                  = "sample-instance"
          + "spannerMetadataDatabase"            = "audit-db"
          + "spannerMetadataInstanceId"          = "sample-instance"
        }
      + project                      = "spanner-gke-443910"
      + region                       = "us-central1"
      + sdk_container_image          = (known after apply)
      + service_account_email        = "dataflow-sa@spanner-gke-443910.iam.gserviceaccount.com"
      + skip_wait_on_job_termination = false
      + staging_location             = (known after apply)
      + state                        = (known after apply)
      + subnetwork                   = "regions/us-central1/subnetworks/custom-dataflow-subnet"
      + temp_location                = "gs://dataflow-temp-spanner-bq-12345/temp"
      + terraform_labels             = {
          + "environment"                = "dev"
          + "goog-terraform-provisioned" = "true"
          + "pipeline"                   = "spanner-to-bigquery"
          + "team"                       = "data"
        }
      + type                         = (known after apply)
    }

  # module.dataflow.google_storage_bucket.dataflow_temp[0] will be created
  + resource "google_storage_bucket" "dataflow_temp" {
      + effective_labels            = {
          + "environment"                = "dev"
          + "goog-terraform-provisioned" = "true"
          + "pipeline"                   = "spanner-to-bigquery"
          + "team"                       = "data"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + labels                      = {
          + "environment" = "dev"
          + "pipeline"    = "spanner-to-bigquery"
          + "team"        = "data"
        }
      + location                    = "US-CENTRAL1"
      + name                        = "dataflow-temp-spanner-bq-12345"
      + project                     = (known after apply)
      + project_number              = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = {
          + "environment"                = "dev"
          + "goog-terraform-provisioned" = "true"
          + "pipeline"                   = "spanner-to-bigquery"
          + "team"                       = "data"
        }
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "Delete"
            }
          + condition {
              + age                   = 30
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.


module.dataflow.google_dataflow_flex_template_job.dataflow_flex_job: Creation complete after 2m9s [id=2025-01-06_17_11_40-7457857020413206573]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
PUSH
DONE

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ID                                    CREATE_TIME                DURATION  SOURCE                                                                                            IMAGES  STATUS
73cffb77-f48b-4484-8fed-f15d4288ab27  2025-01-07T01:11:12+00:00  2M38S     gs://spanner-gke-443910_cloudbuild/source/1736212233.635415-719c8d4ce00f4547bb9774a7e7e59466.tgz  -       SUCCESS

#########

1) Adding a new table on Spanner to the Db & existing changesteam

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT table_name FROM information_schema.tables WHERE table_schema = '';"
table_name
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6
payment_audit_trail
payment_audit_trail_psp


2) Review existing dataflow job

to-bigquery  Streaming  2025-01-05 00:51:47  Cancelled  us-central1
ai-learningharshvardhan@harshvadhansAir terraform % gcloud dataflow jobs list --region us-central1
JOB_ID                                    NAME                 TYPE       CREATION_TIME        STATE      REGION
2025-01-06_17_11_40-7457857020413206573   spanner-to-bigquery  Streaming  2025-01-07 01:11:42  Running    us-central1
2025-01-04_19_37_19-13419870172193443123  spanner-to-bigquery  Streaming  2025-01-05 03:37:19  Cancelled  us-central1


% gcloud dataflow jobs describe  2025-01-06_17_11_40-7457857020413206573 --region=us-central1 --format="yaml"
createTime: '2025-01-07T01:11:42.210514Z'
currentState: JOB_STATE_RUNNING
currentStateTime: '2025-01-07T01:13:39.813231Z'
environment:
  userAgent:
    container.base_repository: gcr.io/cloud-dataflow/v1beta3
    fnapi.container.version: 2.61.0
    fnapi.environment.major.version: '8'
    java.vendor: Eclipse Adoptium
    java.version: 11.0.20
    legacy.container.version: 2.61.0
    legacy.environment.major.version: '8'
    name: Apache Beam SDK for Java
    os.arch: amd64
    os.name: Linux
    os.version: 6.1.112+
    version: 2.61.0
  version:
    job_type: FNAPI_STREAMING
    major: '8'
id: 2025-01-06_17_11_40-7457857020413206573
jobMetadata:
  sdkVersion:
    sdkSupportStatus: SUPPORTED
    version: 2.61.0
    versionDisplayName: Apache Beam SDK for Java
labels:
  environment: dev
  goog-dataflow-provided-template-name: spanner_change_streams_to_bigquery
  goog-dataflow-provided-template-type: flex
  goog-dataflow-provided-template-version: 2024-12-03-00_rc00
  goog-terraform-provisioned: 'true'
  pipeline: spanner-to-bigquery
  team: data
location: us-central1
name: spanner-to-bigquery
projectId: spanner-gke-443910
runtimeUpdatableParams:
  maxNumWorkers: 100
  minNumWorkers: 1
  workerUtilizationHint: 0.8
satisfiesPzi: false
serviceResources:
  zones:
  - us-central1-a
stageStates:
- currentStateTime: '2025-01-07T01:13:59.659Z'
  executionStageName: F174
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F182
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:39.402Z'
  executionStageName: start196
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-07T01:13:59.659Z'
  executionStageName: F178
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F181
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F190
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F188
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F186
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F180
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F189
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:39.402Z'
  executionStageName: Read from Spanner Change Streams/Wait.OnSignal/Wait/Map/ParMultiDo(Anonymous)/View-org.apache.beam.sdk.values.PCollectionViews$SimplePCollectionView.<init>:1931#8bf72308025c8f5f-view-out27
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-07T01:13:59.659Z'
  executionStageName: F176
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F192
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:39.402Z'
  executionStageName: failure195
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-07T01:13:39.402Z'
  executionStageName: Read from Spanner Change Streams/Wait.OnSignal/Wait/Map/ParMultiDo(Anonymous)/View-org.apache.beam.sdk.values.PCollectionViews$SimplePCollectionView.<init>:1931#8bf72308025c8f5f-view26
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-07T01:13:59.659Z'
  executionStageName: F175
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F179
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.659Z'
  executionStageName: F177
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F191
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:39.402Z'
  executionStageName: Read from Spanner Change Streams/Wait.OnSignal/Wait/Map/ParMultiDo(Anonymous)/View-org.apache.beam.sdk.values.PCollectionViews$SimplePCollectionView.<init>:1931#8bf72308025c8f5f-view-writer-out25
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-07T01:13:39.402Z'
  executionStageName: success194
  executionStageState: JOB_STATE_PENDING
- currentStateTime: '2025-01-07T01:13:59.659Z'
  executionStageName: F173
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F185
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F184
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F187
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F193
  executionStageState: JOB_STATE_RUNNING
- currentStateTime: '2025-01-07T01:13:59.660Z'
  executionStageName: F183
  executionStageState: JOB_STATE_RUNNING
startTime: '2025-01-07T01:11:42.210514Z'
type: JOB_TYPE_STREAMING


 gcloud dataflow jobs show  2025-01-06_17_11_40-7457857020413206573 \
    --region=us-central1 \
    --format="json"

{
  "creationTime": "2025-01-07 01:11:42",
  "id": "2025-01-06_17_11_40-7457857020413206573",
  "location": "us-central1",
  "name": "spanner-to-bigquery",
  "state": "Running",
  "stateTime": "2025-01-07 01:13:39",
  "type": "Streaming"
}


#####



3) Current total_rowa in bq table & delete all data:

% bq query --nouse_legacy_sql \
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`" 
+------------+
| total_rows |
+------------+
|      90794 |
+------------+

% bq query --nouse_legacy_sql \
"TRUNCATE TABLE \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"

Waiting on bqjob_rd13b154c72000bc_000001943e5eb987_1 ... (0s) Current status: DONE   
Number of affected rows: 90794

ai-learningharshvardhan@harshvadhansAir terraform % bq query --nouse_legacy_sql \
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"
+------------+
| total_rows |
+------------+
|          0 |
+------------+


% gcloud spanner databases execute-sql audit-db \    --instance=sample-instance \                                                         
    --project=spanner-gke-443910 \                                                                    
    --sql="SELECT COUNT(*) AS total_rows FROM payment_audit_trail"

total_rows
0

ai-learningharshvardhan@harshvadhansAir terraform % bq query --nouse_legacy_sql \                  
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"
+------------+
| total_rows |
+------------+
|          0 |
+------------+



####

**Test case**

1) Manually insert the data into the table monitored by changestream & data should reflect in the biquery via dataflow:


% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT COUNT(*) AS total_rows FROM payment_audit_trail"          

total_rows
107232
ai-learningharshvardhan@harshvadhansAir terraform % gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT COUNT(*) AS total_rows FROM Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6"

total_rows
251
ai-learningharshvardhan@harshvadhansAir terraform % gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT COUNT(*) AS total_rows FROM payment_audit_trail_psp"                               

total_rows
0


####

Now we have zero row in the table ( source)

Spanner table: payment_audit_trail

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT COUNT(*) AS total_rows FROM payment_audit_trail"

total_rows
0

BQ table:

table name: payment_audit_trail_changelog

% bq query --nouse_legacy_sql \
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"
+------------+
| total_rows |
+------------+
|          0 |
+------------+

**Process to delete data from bq & Spanner forcefully**
Create a Temporary Table:

bq query --nouse_legacy_sql \
--destination_table="audit_service_dataset.temp_table" \
"SELECT * FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\` WHERE FALSE"

Drop the Original Table:

bq rm -f spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog

Rename the Temporary Table:

bq cp audit_service_dataset.temp_table audit_service_dataset.payment_audit_trail_changelog
bq rm -f spanner-gke-443910.audit_service_dataset.temp_table

gcloud spanner databases execute-sql audit-db \    --instance=sample-instance \                                                                               
    --project=spanner-gke-443910 \
    --sql="DELETE FROM payment_audit_trail WHERE TRUE"






###

Add same data to the Source :

Spanner - Inserted record: 'PUID': 'f0c7b098-6d9f-4e02-8877-1b853fe8c086'

```


```

New data comes to destination :

BigQuery - New row: 'PUID': 'f0c7b098-6d9f-4e02-8877-1b853fe8c086'

% bq query --nouse_legacy_sql \
"SELECT * FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`
 ORDER BY Timestamp DESC
 LIMIT 2;" |grep -i f0c7b098-6d9f-4e02-8877-1b853fe8c086
| f0c7b098-6d9f-4e02-8877-1b853fe8c086 | CREATE_PAYMENT | 2025-01-07 02:39:41 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | payment_audit_trail          |                2025-01-07 02:39:43 | Mzk4ODY2Mzg4NjA1NDY3OTk2NA==            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-07 02:39:48 |
ai-learningharshvardhan@harshvadhansAir terraform % 

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT COUNT(*) AS total_rows FROM payment_audit_trail"
total_rows
75
ai-learningharshvardhan@harshvadhansAir terraform % bq query --nouse_legacy_sql \                  
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"
+------------+
| total_rows |
+------------+
|         75 |
+------------+

Output: Success

######


Usecase2:

Creating a new table on spanner & enabling the existing changestream on that:

New table is : payment_audit_trail_psp
existing change stream config:
SELECT CHANGE_STREAM_NAME, TABLE_NAME
FROM INFORMATION_SCHEMA.CHANGE_STREAM_TABLES
WHERE CHANGE_STREAM_NAME = 'audit_db_change_stream';

CHANGE_STREAM_NAME     TABLE_NAME
audit_db_change_stream payment_audit_trail

**IMPORTANT**
Cloud Spanner, Change Streams cannot currently be altered or updated after they are created. Once a Change Stream is created, its configuration, including the tables and columns it tracks, is immutable.

No direct support for adding multiple tables to an existing Change Stream via ALTER CHANGE STREAM. Spanner Change Streams only support watching a single table at a time. You cannot add additional tables to an existing Change Stream.

Workaround: To include more tables in a Change Stream, you'll need to create a new Change Stream that includes all the tables you want to monitor. Unfortunately, as of now, Spanner does not allow modifying an existing Change Stream to include additional tables.

** So need to create new change-stream for this new table.

- Name of change stream is : audit_db_change_stream_v2
- Created a new dataflow job for this change stream where the destination bq (dataset and table) is same to ensure single source of truth for audit data

parameters = 
  spannerInstanceId          = "sample-instance"
  spannerDatabase            = "audit-db"
  spannerMetadataInstanceId  = "sample-instance"
  spannerMetadataDatabase    = "audit-db"
  spannerChangeStreamName    = "audit_db_change_stream_v2" --> New change stream
  bigQueryDataset            = "audit_service_dataset"
  bigQueryChangelogTableNameTemplate = "payment_audit_trail_changelog"


% gcloud dataflow jobs list --region us-central1
JOB_ID                                    NAME                    TYPE       CREATION_TIME        STATE      REGION
2025-01-06_21_16_19-13002277393968768368  spanner-to-bigquery-qa  Streaming  2025-01-07 05:16:19  Running    us-central1
2025-01-06_17_11_40-7457857020413206573   spanner-to-bigquery     Streaming  2025-01-07 01:11:42  Running    us-central1

- New dataflow job is created with name: 2025-01-06_21_16_19-13002277393968768368 


### LETS create secnerio , where we write on this new table < payment_audit_trail_psp> & see, if data getting streamed to BQ or not.

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="
        SELECT
            t.table_name,
            c.column_name,
            c.spanner_type,
            c.is_nullable
        FROM
            information_schema.tables AS t
        JOIN
            information_schema.columns AS c
        ON
            t.table_name = c.table_name
        WHERE
            t.table_schema = ''
        ORDER BY
            t.table_name, c.ordinal_position;"
table_name                                              column_name      spanner_type        is_nullable
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  PartitionToken   STRING(MAX)         NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  ParentTokens     ARRAY<STRING(MAX)>  NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  StartTimestamp   TIMESTAMP           NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  EndTimestamp     TIMESTAMP           NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  HeartbeatMillis  INT64               NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  State            STRING(MAX)         NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  Watermark        TIMESTAMP           NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  CreatedAt        TIMESTAMP           NO
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  ScheduledAt      TIMESTAMP           YES
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  RunningAt        TIMESTAMP           YES
Metadata_audit_db_3017dd79_c6d9_4e2e_ad54_16dfd49398d6  FinishedAt       TIMESTAMP           YES
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  PartitionToken   STRING(MAX)         NO
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  ParentTokens     ARRAY<STRING(MAX)>  NO
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  StartTimestamp   TIMESTAMP           NO
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  EndTimestamp     TIMESTAMP           NO
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  HeartbeatMillis  INT64               NO
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  State            STRING(MAX)         NO
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  Watermark        TIMESTAMP           NO
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  CreatedAt        TIMESTAMP           NO
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  ScheduledAt      TIMESTAMP           YES
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  RunningAt        TIMESTAMP           YES
Metadata_audit_db_64654ee8_8d91_42c3_9067_ddcbbc567c78  FinishedAt       TIMESTAMP           YES
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  PartitionToken   STRING(MAX)         NO
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  ParentTokens     ARRAY<STRING(MAX)>  NO
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  StartTimestamp   TIMESTAMP           NO
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  EndTimestamp     TIMESTAMP           NO
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  HeartbeatMillis  INT64               NO
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  State            STRING(MAX)         NO
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  Watermark        TIMESTAMP           NO
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  CreatedAt        TIMESTAMP           NO
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  ScheduledAt      TIMESTAMP           YES
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  RunningAt        TIMESTAMP           YES
Metadata_audit_db_d2df976c_172c_4ef2_8098_8e35565268ef  FinishedAt       TIMESTAMP           YES
payment_audit_trail                                     PUID             STRING(36)          NO
payment_audit_trail                                     Action           STRING(100)         NO
payment_audit_trail                                     Status           STRING(50)          YES
payment_audit_trail                                     Timestamp        TIMESTAMP           NO
payment_audit_trail                                     ServiceName      STRING(100)         YES
payment_audit_trail                                     Metadata         JSON                YES
payment_audit_trail                                     RetryCount       INT64               YES
payment_audit_trail                                     ErrorDetails     STRING(500)         YES
payment_audit_trail_psp                                 PUID             STRING(36)          NO
payment_audit_trail_psp                                 Action           STRING(100)         NO
payment_audit_trail_psp                                 Status           STRING(50)          YES
payment_audit_trail_psp                                 Timestamp        TIMESTAMP           NO
payment_audit_trail_psp                                 ServiceName      STRING(100)         YES
payment_audit_trail_psp                                 Metadata         JSON                YES
payment_audit_trail_psp                                 RetryCount       INT64               YES
payment_audit_trail_psp                                 ErrorDetails     STRING(500)         YES


% bq query --nouse_legacy_sql \
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"
+------------+
| total_rows |
+------------+
|         78 |
+------------+
ai-learningharshvardhan@harshvadhansAir terraform % bq query --nouse_legacy_sql \
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"
+------------+
| total_rows |
+------------+
|         79 |
+------------+


Usecase 3:


## Add a New Column in Existing DB and Observe Changes

### Output:

#### Before Scenario:

```bash
% bq query --nouse_legacy_sql \
"SELECT COUNT(*) AS total_rows FROM `spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog`"

+------------+
| total_rows |
+------------+
|          0 |
+------------+

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT COUNT(*) AS total_rows FROM payment_audit_trail"

total_rows
0

Table Schema Before Adding Columns:
Table Name	Column Name	Type	Nullable
payment_audit_trail_psp	PUID	STRING(36)	NO
payment_audit_trail_psp	Action	STRING(100)	NO
payment_audit_trail_psp	Status	STRING(50)	YES
payment_audit_trail_psp	Timestamp	TIMESTAMP	NO
payment_audit_trail_psp	ServiceName	STRING(100)	YES
payment_audit_trail_psp	Metadata	JSON	YES
payment_audit_trail_psp	RetryCount	INT64	YES
payment_audit_trail_psp	ErrorDetails	STRING(500)	YES

Table Schema After Adding Columns:

% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT column_name FROM information_schema.columns WHERE table_name = 'payment_audit_trail_psp';"

Output
column_name
PUID
Action
Status
Timestamp
ServiceName
Metadata
RetryCount
ErrorDetails
UserId
Source
TransactionId
Processed


Complete Schema After Adding Columns:
Table Name	Column Name	Type	Nullable
payment_audit_trail_psp	PUID	STRING(36)	NO
payment_audit_trail_psp	Action	STRING(100)	NO
payment_audit_trail_psp	Status	STRING(50)	YES
payment_audit_trail_psp	Timestamp	TIMESTAMP	NO
payment_audit_trail_psp	ServiceName	STRING(100)	YES
payment_audit_trail_psp	Metadata	JSON	YES
payment_audit_trail_psp	RetryCount	INT64	YES
payment_audit_trail_psp	ErrorDetails	STRING(500)	YES
payment_audit_trail_psp	UserId	STRING(100)	YES
payment_audit_trail_psp	Source	STRING(100)	YES
payment_audit_trail_psp	TransactionId	STRING(100)	YES
payment_audit_trail_psp	Processed	BOOL	YES


Destination BigQuery:

% bq show spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog

Table spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog

   Last modified                                     Schema                                    Total Rows   Total Bytes   
 ----------------- -------------------------------------------------------------------------- ------------ ------------- 
  07 Jan 18:14:41   |- PUID: string                                                            0            0           
                    |- Action: string                                                                                  
                    |- Timestamp: timestamp                                                                            
                    |- Status: string                                                                                  
                    |- ServiceName: string                                                                             
                    |- Metadata: json                                                                                  
                    |- RetryCount: integer                                                                             
                    |- ErrorDetails: string                                                                            
                    |- _metadata_spanner_mod_type: string                                                              
                    |- _metadata_spanner_table_name: string                                                            
                    |- _metadata_spanner_commit_timestamp: timestamp                                                   
                    |- _metadata_spanner_server_transaction_id: string                                                 
                    |- _metadata_spanner_record_sequence: string                                                       
                    |- _metadata_spanner_is_last_record_in_transaction_in_partition: boolean                           
                    |- _metadata_spanner_number_of_records_in_transaction: integer                                     
                    |- _metadata_spanner_number_of_partitions_in_transaction: integer                                  
                    |- _metadata_big_query_commit_timestamp: timestamp                                                 


Error Observed in Dataflow Job:


{
  "code": 404,
  "message": "Not found: Table spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog",
  "status": "NOT_FOUND"
}


2025-01-07 14:58:02.364 AEDT
Error message from worker: generic::unknown: org.apache.beam.sdk.util.UserCodeException: java.lang.RuntimeException: com.google.api.client.googleapis.json.GoogleJsonResponseException: 404 Not Found
POST https://bigquery.googleapis.com/bigquery/v2/projects/spanner-gke-443910/datasets/audit_service_dataset/tables/payment_audit_trail_changelog/insertAll?prettyPrint=false
{
  "code": 404,
  "errors": [
    {
      "domain": "global",
      "message": "Table is truncated.",
      "reason": "notFound"
    }

Resolution:

% bq update --schema 'PUID:STRING,Action:STRING,Status:STRING,Timestamp:TIMESTAMP,ServiceName:STRING,Metadata:JSON,RetryCount:INTEGER,ErrorDetails:STRING,_metadata_spanner_mod_type:STRING,_metadata_spanner_table_name:STRING,_metadata_spanner_commit_timestamp:TIMESTAMP,_metadata_spanner_server_transaction_id:STRING,_metadata_spanner_record_sequence:STRING,_metadata_spanner_is_last_record_in_transaction_in_partition:BOOLEAN,_metadata_spanner_number_of_records_in_transaction:INTEGER,_metadata_spanner_number_of_partitions_in_transaction:INTEGER,_metadata_big_query_commit_timestamp:TIMESTAMP,UserId:STRING,Source:STRING,TransactionId:STRING,Processed:BOOLEAN' spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog


Output

Table 'spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog' successfully updated.


Post-Resolution Verification:

+------------+
| total_rows |
+------------+
|         98 |
+------------+


% gcloud spanner databases execute-sql audit-db \
    --instance=sample-instance \
    --project=spanner-gke-443910 \
    --sql="SELECT COUNT(*) AS total_rows FROM payment_audit_trail_psp"

Output

total_rows
115

Observation, few of entries missed during this on-fly changes & this is can be handled properly.






