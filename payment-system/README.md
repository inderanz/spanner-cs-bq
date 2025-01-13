
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


Test Cases

1) Manually Insert Data into the Table Monitored by ChangeStream & Ensure Data Reflection in BigQuery via Dataflow
Insert Data into Spanner Table
























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

[2025-01-07T02:39:44.007100+00:00] Logged to BigQuery: Spanner - Inserted record: {'PUID': 'f0c7b098-6d9f-4e02-8877-1b853fe8c086', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 7, 2, 39, 41, 790220, tzinfo=datetime.timezone.utc), 'ServiceName': 'PaymentService', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
Inserted record into Spanner: {'PUID': 'f0c7b098-6d9f-4e02-8877-1b853fe8c086', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 7, 2, 39, 41, 790220, tzinfo=datetime.timezone.utc), 'ServiceName': 'PaymentService', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
[2025-01-07T02:39:50.124079+00:00] Logged to BigQuery: BigQuery - New row: {'PUID': 'f0c7b098-6d9f-4e02-8877-1b853fe8c086', 'Action': 'CREATE_PAYMENT', 'Timestamp': datetime.datetime(2025, 1, 7, 2, 39, 41, 790220, tzinfo=datetime.timezone.utc), 'Status': 'SUCCESS', 'ServiceName': 'PaymentService', 'Metadata': {'amount': 100.5, 'currency': 'USD'}, 'RetryCount': 0, 'ErrorDetails': None, '_metadata_spanner_mod_type': 'INSERT', '_metadata_spanner_table_name': 'payment_audit_trail', '_metadata_spanner_commit_timestamp': datetime.datetime(2025, 1, 7, 2, 39, 43, 676607, tzinfo=datetime.timezone.utc), '_metadata_spanner_server_transaction_id': 'Mzk4ODY2Mzg4NjA1NDY3OTk2NA==', '_metadata_spanner_record_sequence': '00000000', '_metadata_spanner_is_last_record_in_transaction_in_partition': True, '_metadata_spanner_number_of_records_in_transaction': 1, '_metadata_spanner_number_of_partitions_in_transaction': 1, '_metadata_big_query_commit_timestamp': datetime.datetime(2025, 1, 7, 2, 39, 48, 242122, tzinfo=datetime.timezone.utc)}

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
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`;"

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
% bq query --nouse_legacy_sql "SELECT COUNT(*) AS total_rows FROM `spanner-gke-443910.audit_service_datasetpayment_audit_trail_changelog`"

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




####


Usecase: A new DB and a diffrent change stream stream to same BQ dataset & table

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



2) DDL - DB & its table information with change stream enabled

CREATE TABLE Payments (
  PaymentUID STRING(36) NOT NULL,
  UserId STRING(100),
  Amount FLOAT64,
  Status STRING(50),
  Timestamp TIMESTAMP,
) PRIMARY KEY(PaymentUID);

CREATE TABLE Reconciliation (
  PUID STRING(36) NOT NULL,
  Amount FLOAT64,
  Status STRING(50),
  Timestamp TIMESTAMP,
) PRIMARY KEY(PUID);

CREATE TABLE Transactions (
  PUID STRING(36) NOT NULL,
  UserId STRING(100),
  Amount FLOAT64,
  Status STRING(50),
  Timestamp TIMESTAMP,
) PRIMARY KEY(PUID);

CREATE TABLE payment_audit_trail (
  PUID STRING(36) NOT NULL,
  Action STRING(100),
  Status STRING(50),
  Timestamp TIMESTAMP,
) PRIMARY KEY(PUID);

CREATE CHANGE STREAM shared_audit_db_cs
  FOR ALL;


3) Creating a new ChangeStream job for this DB & change stream with same destination BQ & Table


# Job Configuration
job_name           = "spanner-to-bigquery-shared-db"
template_gcs_path  = "gs://dataflow-templates-us-central1/2024-12-03-00_RC00/flex/Spanner_Change_Streams_to_BigQuery"
parameters = 
  spannerInstanceId          = "sample-instance"
  spannerDatabase            = "shared-db"
  spannerMetadataInstanceId  = "sample-instance"
  spannerMetadataDatabase    = "shared-db"
  spannerChangeStreamName    = "shared_audit_db_cs"
  bigQueryDataset            = "audit_service_dataset"
  bigQueryChangelogTableNameTemplate = "payment_audit_trail_changelog"


% gcloud dataflow jobs list --region us-central1
JOB_ID                                    NAME                           TYPE       CREATION_TIME        STATE      REGION
2025-01-07_03_47_45-3937567032289522483   spanner-to-bigquery-shared-db  Streaming  2025-01-07 11:47:45  Running    us-central1
2025-01-06_22_15_17-10964669824617826418  spanner-to-bigquery-qa         Streaming  2025-01-07 06:15:17  Running    us-central1
2025-01-06_17_11_40-7457857020413206573   spanner-to-bigquery            Streaming  2025-01-07 01:11:42  Running    us-central1



4) BQ dataset & its current table columns


% bq show --format=pretty spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog

Table spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog

+-----------------+--------------------------------------------------------------------------+------------+-------------+------------+-------------------+------------------+---------------------+----------------------+--------+
|  Last modified  |                                  Schema                                  | Total Rows | Total Bytes | Expiration | Time Partitioning | Clustered Fields | Total Logical Bytes | Total Physical Bytes | Labels |
+-----------------+--------------------------------------------------------------------------+------------+-------------+------------+-------------------+------------------+---------------------+----------------------+--------+
| 07 Jan 20:10:43 | |- PUID: string                                                          | 2444       | 500883      |            |                   |                  | 500883              | 106674               |        |
|                 | |- Action: string                                                        |            |             |            |                   |                  |                     |                      |        |
|                 | |- Timestamp: timestamp                                                  |            |             |            |                   |                  |                     |                      |        |
|                 | |- Status: string                                                        |            |             |            |                   |                  |                     |                      |        |
|                 | |- ServiceName: string                                                   |            |             |            |                   |                  |                     |                      |        |
|                 | |- Metadata: json                                                        |            |             |            |                   |                  |                     |                      |        |
|                 | |- RetryCount: integer                                                   |            |             |            |                   |                  |                     |                      |        |
|                 | |- ErrorDetails: string                                                  |            |             |            |                   |                  |                     |                      |        |
|                 | |- _metadata_spanner_mod_type: string                                    |            |             |            |                   |                  |                     |                      |        |
|                 | |- _metadata_spanner_table_name: string                                  |            |             |            |                   |                  |                     |                      |        |
|                 | |- _metadata_spanner_commit_timestamp: timestamp                         |            |             |            |                   |                  |                     |                      |        |
|                 | |- _metadata_spanner_server_transaction_id: string                       |            |             |            |                   |                  |                     |                      |        |
|                 | |- _metadata_spanner_record_sequence: string                             |            |             |            |                   |                  |                     |                      |        |
|                 | |- _metadata_spanner_is_last_record_in_transaction_in_partition: boolean |            |             |            |                   |                  |                     |                      |        |
|                 | |- _metadata_spanner_number_of_records_in_transaction: integer           |            |             |            |                   |                  |                     |                      |        |
|                 | |- _metadata_spanner_number_of_partitions_in_transaction: integer        |            |             |            |                   |                  |                     |                      |        |
|                 | |- _metadata_big_query_commit_timestamp: timestamp                       |            |             |            |                   |                  |                     |                      |        |
|                 | |- UserId: string                                                        |            |             |            |                   |                  |                     |                      |        |
|                 | |- Source: string                                                        |            |             |            |                   |                  |                     |                      |        |
|                 | |- TransactionId: string                                                 |            |             |            |                   |                  |                     |                      |        |
|                 | |- Processed: boolean                                                    |            |             |            |                   |                  |                     |                      |        |
+-----------------+--------------------------------------------------------------------------+------------+-------------+------------+-------------------+------------------+---------------------+----------------------+--------+


vs

Current Schema for the services:

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


###

So, we all the columns in BQ Table.

###
Before pushing the payload the row count:

% bq query --nouse_legacy_sql \
"SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`;"

+------------+
| total_rows |
+------------+
|       2444 |
+------------+


% gcloud spanner databases execute-sql  shared-db --instance=sample-instance  --project=spanner-gke-443910 --sql="SELECT COUNT(*) AS total_rows FROM  Payments"
total_rows
9695

% gcloud spanner databases execute-sql  shared-db --instance=sample-instance  --project=spanner-gke-443910 --sql="SELECT COUNT(*) AS total_rows FROM  Reconciliation"
total_rows
9524

% gcloud spanner databases execute-sql  shared-db --instance=sample-instance  --project=spanner-gke-443910 --sql="SELECT COUNT(*) AS total_rows FROM  Transactions"  
total_rows
9695


 % gcloud spanner databases execute-sql  shared-db --instance=sample-instance  --project=spanner-gke-443910 --sql="SELECT COUNT(*) AS total_rows FROM  payment_audit_trail"
total_rows
0


Issue Summary
The issue arises when attempting to query metadata or consume data from a Cloud Spanner change stream (shared_audit_db_cs) via SQL. Despite the change stream appearing correctly configured in the Google Cloud Console UI, the SQL queries return no results or raise errors. This inconsistency suggests a possible bug in Cloud Spanner's change stream metadata handling or SQL functionality.

Steps to Reproduce
Create a Change Stream in Cloud Spanner:

A change stream named shared_audit_db_cs is created and associated with tables (payment_audit_trail, Payments, Reconciliation, Transactions) in the database shared-db.
Verify Change Stream in UI:

Navigate to the Spanner instance (sample-instance) and database (shared-db) in the Google Cloud Console.
The shared_audit_db_cs change stream is visible under the Change Streams section, and it correctly lists the associated tables.
Execute SQL to List Change Streams:

bash
Copy code
gcloud spanner databases execute-sql shared-db \
  --instance=sample-instance \
  --sql="SELECT CHANGE_STREAM_NAME FROM INFORMATION_SCHEMA.CHANGE_STREAMS;"
Output: The query returns the change stream shared_audit_db_cs.
Execute SQL to Retrieve Tables Associated with the Change Stream:

bash
Copy code
gcloud spanner databases execute-sql shared-db \
  --instance=sample-instance \
  --sql="SELECT TABLE_NAME FROM INFORMATION_SCHEMA.CHANGE_STREAM_TABLES WHERE CHANGE_STREAM_NAME = 'shared_audit_db_cs';"
Output: No rows are returned, despite the UI showing the associated tables.
Attempt to Consume Data Using READ_CHANGE_STREAM:

bash
Copy code
gcloud spanner databases execute-sql shared-db \
  --instance=sample-instance \
  --sql="SELECT * FROM READ_CHANGE_STREAM('shared_audit_db_cs', CURRENT_TIMESTAMP() - INTERVAL 10 MINUTE, CURRENT_TIMESTAMP());"
Output:
sql
Copy code
ERROR: (gcloud.spanner.databases.execute-sql) INVALID_ARGUMENT: Table-valued function not found: READ_CHANGE_STREAM
Observed Behavior
UI Behavior:
The shared_audit_db_cs change stream appears correctly configured and lists associated tables (payment_audit_trail, Payments, Reconciliation, Transactions).
SQL Behavior:
The INFORMATION_SCHEMA.CHANGE_STREAMS query confirms the existence of the change stream.
The INFORMATION_SCHEMA.CHANGE_STREAM_TABLES query returns no rows, indicating no table associations.
The READ_CHANGE_STREAM function raises an error (Table-valued function not found), preventing data consumption.
Expected Behavior
The query SELECT TABLE_NAME FROM INFORMATION_SCHEMA.CHANGE_STREAM_TABLES WHERE CHANGE_STREAM_NAME = 'shared_audit_db_cs'; should return the associated tables (payment_audit_trail, Payments, Reconciliation, Transactions).
The READ_CHANGE_STREAM function should return rows if the change stream is capturing changes.
Implications
Operational Impact: The inconsistency between the UI and SQL results makes it difficult to validate change stream configurations or consume change data programmatically.
Suspected Cause: This could be a metadata synchronization issue or a bug in the INFORMATION_SCHEMA or READ_CHANGE_STREAM functionality.



Issue Summary
The issue arises when a change stream is created using the FOR ALL option in Cloud Spanner. While the Google Cloud Console UI displays the change stream and its dynamically associated tables, querying the INFORMATION_SCHEMA.CHANGE_STREAM_TABLES view and consuming the change stream using READ_CHANGE_STREAM fail.

Steps to Reproduce
Create a change stream in the database shared-db using the FOR ALL option:
sql
Copy code
CREATE CHANGE STREAM shared_audit_db_cs FOR ALL;
Verify the change stream in the Google Cloud Console UI.
Observed: The UI lists the change stream and shows associated tables (payment_audit_trail, Payments, Reconciliation, Transactions).
Run the following SQL queries:
List Change Streams:
sql
Copy code
SELECT CHANGE_STREAM_NAME FROM INFORMATION_SCHEMA.CHANGE_STREAMS;
Output: shared_audit_db_cs
List Associated Tables:
sql
Copy code
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.CHANGE_STREAM_TABLES WHERE CHANGE_STREAM_NAME = 'shared_audit_db_cs';
Output: No rows.
Consume Change Stream:
sql
Copy code
SELECT * FROM READ_CHANGE_STREAM('shared_audit_db_cs', CURRENT_TIMESTAMP() - INTERVAL 10 MINUTE, CURRENT_TIMESTAMP());
Output:
sql
Copy code
ERROR: (gcloud.spanner.databases.execute-sql) INVALID_ARGUMENT: Table-valued function not found: READ_CHANGE_STREAM
Observed Behavior
The INFORMATION_SCHEMA.CHANGE_STREAM_TABLES view does not list any tables for the shared_audit_db_cs change stream.
The READ_CHANGE_STREAM function fails with an error, making it impossible to consume changes programmatically.
The Google Cloud Console UI shows the change stream as watching all tables, consistent with the FOR ALL option.
Expected Behavior
The INFORMATION_SCHEMA.CHANGE_STREAM_TABLES view should dynamically reflect all tables being watched by a FOR ALL change stream.
The READ_CHANGE_STREAM function should allow querying changes for the FOR ALL change stream.
Possible Cause
The behavior suggests a potential bug or limitation in Cloud Spanner's handling of FOR ALL change streams:

Metadata inconsistency between the INFORMATION_SCHEMA views and the UI.
Configuration or compatibility issues with the READ_CHANGE_STREAM function for FOR ALL change streams.

**Issue**

The data is not coming up into the bigquery.

Command to check the logs of dataflow job.

gcloud logging read "resource.type=dataflow_step AND resource.labels.job_id=2025-01-07_05_24_44-13571876371196309811" \
    --project=spanner-gke-443910 \
    --format="json" \
    --limit=21 


 % gcloud spanner databases execute-sql shared-db \
  --instance=sample-instance \
  --sql="SELECT *
         FROM READ_CHANGE_STREAM(
           'shared_audit_db_cs',
           TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 10 MINUTE),
           CURRENT_TIMESTAMP()
         );"

ERROR: (gcloud.spanner.databases.execute-sql) INVALID_ARGUMENT: Table-valued function not found: READ_CHANGE_STREAM [at 2:15]\n         FROM READ_CHANGE_STREAM(\n              ^
Table-valued function not found: READ_CHANGE_STREAM [at 2:15]
         FROM READ_CHANGE_STREAM(
              ^   

####

Its working now

% bq query --nouse_legacy_sql "SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"

+------------+
| total_rows |
+------------+
|       6164 |
+------------+
ai-learningharshvardhan@harshvadhansAir payment-system % gcloud spanner databases execute-sql shared-db \
  --instance=sample-instance \
  --sql="SELECT * FROM test_table LIMIT 10;"

PUID                                  Action          Status   Timestamp                       ServiceName     Metadata                           RetryCount  ErrorDetails
1                                     InsertAction    Success  2025-01-07T23:49:30.182579123Z  ServiceTest     {"key":"value"}                    1           No error
119099ca-f106-40e2-83fb-aeadc48c6d3e  CREATE_PAYMENT  SUCCESS  2025-01-08T00:49:04.588023Z     PaymentService  {"amount":100.5,"currency":"USD"}  0
1234                                  InsertTest      None     2025-01-07T23:52:24.222380897Z
2                                     UpdateAction    Pending  2025-01-07T23:49:30.182579123Z  AnotherService  None                               0           Retry needed
22f240c2-b6f4-4959-8f27-b7db304dde31  CREATE_PAYMENT  SUCCESS  2025-01-08T00:48:41.238672Z     PaymentService  {"amount":100.5,"currency":"USD"}  0
2543bd55-071a-4bca-afc2-a671aac3c4ff  CREATE_PAYMENT  SUCCESS  2025-01-08T00:48:35.44206Z      PaymentService  {"amount":100.5,"currency":"USD"}  0
42094c9d-f279-4a6f-930d-0ce2695ce7a2  CREATE_PAYMENT  SUCCESS  2025-01-08T00:48:52.945627Z     PaymentService  {"amount":100.5,"currency":"USD"}  0
45f6543e-298f-4c75-9771-26f1ccfeb726  CREATE_PAYMENT  SUCCESS  2025-01-08T00:48:58.702891Z     PaymentService  {"amount":100.5,"currency":"USD"}  0
6953ee71-a880-4071-9b3b-18a605eea916  CREATE_PAYMENT  SUCCESS  2025-01-08T00:48:17.177393Z     PaymentService  {"amount":100.5,"currency":"USD"}  0
7655f33a-21af-4c3a-b730-f2382be0e329  CREATE_PAYMENT  SUCCESS  2025-01-08T00:49:10.46284Z      PaymentService  {"amount":100.5,"currency":"USD"}  0
ai-learningharshvardhan@harshvadhansAir payment-system % 
ai-learningharshvardhan@harshvadhansAir payment-system % 
ai-learningharshvardhan@harshvadhansAir payment-system % 
ai-learningharshvardhan@harshvadhansAir payment-system % bq query --nouse_legacy_sql \
  "SELECT * FROM spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog \
   ORDER BY Timestamp DESC LIMIT 10;"

+--------------------------------------+----------------+---------------------+---------+----------------+-----------------------------------+------------+--------------+----------------------------+------------------------------+------------------------------------+-----------------------------------------+-----------------------------------+--------------------------------------------------------------+----------------------------------------------------+-------------------------------------------------------+--------------------------------------+--------+--------+---------------+-----------+
|                 PUID                 |     Action     |      Timestamp      | Status  |  ServiceName   |             Metadata              | RetryCount | ErrorDetails | _metadata_spanner_mod_type | _metadata_spanner_table_name | _metadata_spanner_commit_timestamp | _metadata_spanner_server_transaction_id | _metadata_spanner_record_sequence | _metadata_spanner_is_last_record_in_transaction_in_partition | _metadata_spanner_number_of_records_in_transaction | _metadata_spanner_number_of_partitions_in_transaction | _metadata_big_query_commit_timestamp | UserId | Source | TransactionId | Processed |
+--------------------------------------+----------------+---------------------+---------+----------------+-----------------------------------+------------+--------------+----------------------------+------------------------------+------------------------------------+-----------------------------------------+-----------------------------------+--------------------------------------------------------------+----------------------------------------------------+-------------------------------------------------------+--------------------------------------+--------+--------+---------------+-----------+
| fac161cf-a544-4471-96e6-b6883b08a839 | CREATE_PAYMENT | 2025-01-08 00:49:16 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:49:16 | MjAxMDU2MjkzMjkwNjUzODU0OQ==            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:49:23 | NULL   | NULL   | NULL          |      NULL |
| 7655f33a-21af-4c3a-b730-f2382be0e329 | CREATE_PAYMENT | 2025-01-08 00:49:10 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:49:10 | MTgzMzE4NjUzMjc4MDY4NzQwOTI=            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:49:15 | NULL   | NULL   | NULL          |      NULL |
| 119099ca-f106-40e2-83fb-aeadc48c6d3e | CREATE_PAYMENT | 2025-01-08 00:49:04 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:49:05 | OTA1NTI4MTUxNjE0NDcwMDIwNA==            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:49:09 | NULL   | NULL   | NULL          |      NULL |
| 45f6543e-298f-4c75-9771-26f1ccfeb726 | CREATE_PAYMENT | 2025-01-08 00:48:58 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:48:59 | MTgzMjcwNzM5MTE3ODA3NjI4Mzc=            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:49:03 | NULL   | NULL   | NULL          |      NULL |
| 42094c9d-f279-4a6f-930d-0ce2695ce7a2 | CREATE_PAYMENT | 2025-01-08 00:48:52 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:48:53 | MTA3NDcyODk3MzM2ODc2ODgzMDc=            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:48:57 | NULL   | NULL   | NULL          |      NULL |
| fc6bdbee-e9ef-4384-8135-abc455e71d9b | CREATE_PAYMENT | 2025-01-08 00:48:47 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:48:47 | MTExMDUyNzk3OTk5NzQ3MDIwMzE=            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:48:51 | NULL   | NULL   | NULL          |      NULL |
| 22f240c2-b6f4-4959-8f27-b7db304dde31 | CREATE_PAYMENT | 2025-01-08 00:48:41 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:48:41 | ODE1NjE0Mzc0OTE0NzYwNTY3MA==            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:48:44 | NULL   | NULL   | NULL          |      NULL |
| 2543bd55-071a-4bca-afc2-a671aac3c4ff | CREATE_PAYMENT | 2025-01-08 00:48:35 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:48:35 | MTE4MjAwNDYwMDg0NjY0NTg4MjQ=            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:48:44 | NULL   | NULL   | NULL          |      NULL |
| fbfcc060-4b1f-484d-9ac1-9993ba3a3a7b | CREATE_PAYMENT | 2025-01-08 00:48:29 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:48:30 | NDE4MDgzMjY1OTgwODExMTEz                | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:48:36 | NULL   | NULL   | NULL          |      NULL |
| d35b6718-f13d-4d16-87b7-df9e8edafbd3 | CREATE_PAYMENT | 2025-01-08 00:48:24 | SUCCESS | PaymentService | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 00:48:24 | MTY1OTY0MjQyNjAxNzAzODEwODc=            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 00:48:30 | NULL   | NULL   | NULL          |      NULL |
+--------------------------------------+----------------+---------------------+---------+----------------+-----------------------------------+------------+--------------+----------------------------+------------------------------+------------------------------------+-----------------------------------------+-----------------------------------+--------------------------------------------------------------+----------------------------------------------------+-------------------------------------------------------+--------------------------------------+--------+--------+---------------+-----------+
ai-learningharshvardhan@harshvadhansAir payment-system % 
ai-learningharshvardhan@harshvadhansAir payment-system % bq query --nouse_legacy_sql \
  "SELECT * FROM spanner-gke-443910.audit_service_dataset.showcase_log \
   ORDER BY log_time DESC LIMIT 10;"

+---------------------+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|      log_time       |  source  |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              log_details                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
+---------------------+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 2025-01-08 00:49:16 | BigQuery | New row: {'PUID': '7655f33a-21af-4c3a-b730-f2382be0e329', 'Action': 'CREATE_PAYMENT', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 49, 10, 462840, tzinfo=datetime.timezone.utc), 'Status': 'SUCCESS', 'ServiceName': 'PaymentService', 'Metadata': {'amount': 100.5, 'currency': 'USD'}, 'RetryCount': 0, 'ErrorDetails': None, '_metadata_spanner_mod_type': 'INSERT', '_metadata_spanner_table_name': 'test_table', '_metadata_spanner_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 49, 10, 914767, tzinfo=datetime.timezone.utc), '_metadata_spanner_server_transaction_id': 'MTgzMzE4NjUzMjc4MDY4NzQwOTI=', '_metadata_spanner_record_sequence': '00000000', '_metadata_spanner_is_last_record_in_transaction_in_partition': True, '_metadata_spanner_number_of_records_in_transaction': 1, '_metadata_spanner_number_of_partitions_in_transaction': 1, '_metadata_big_query_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 49, 15, 168786, tzinfo=datetime.timezone.utc), 'UserId': None, 'Source': None, 'TransactionId': None, 'Processed': None} |
| 2025-01-08 00:49:16 | Spanner  | Inserted record: {'PUID': 'fac161cf-a544-4471-96e6-b6883b08a839', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 49, 16, 254435, tzinfo=datetime.timezone.utc), 'ServiceName': 'PaymentService', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 2025-01-08 00:49:16 | BigQuery | New row: {'PUID': '119099ca-f106-40e2-83fb-aeadc48c6d3e', 'Action': 'CREATE_PAYMENT', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 49, 4, 588023, tzinfo=datetime.timezone.utc), 'Status': 'SUCCESS', 'ServiceName': 'PaymentService', 'Metadata': {'amount': 100.5, 'currency': 'USD'}, 'RetryCount': 0, 'ErrorDetails': None, '_metadata_spanner_mod_type': 'INSERT', '_metadata_spanner_table_name': 'test_table', '_metadata_spanner_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 49, 5, 56111, tzinfo=datetime.timezone.utc), '_metadata_spanner_server_transaction_id': 'OTA1NTI4MTUxNjE0NDcwMDIwNA==', '_metadata_spanner_record_sequence': '00000000', '_metadata_spanner_is_last_record_in_transaction_in_partition': True, '_metadata_spanner_number_of_records_in_transaction': 1, '_metadata_spanner_number_of_partitions_in_transaction': 1, '_metadata_big_query_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 49, 9, 449725, tzinfo=datetime.timezone.utc), 'UserId': None, 'Source': None, 'TransactionId': None, 'Processed': None}     |
| 2025-01-08 00:49:10 | Spanner  | Inserted record: {'PUID': '7655f33a-21af-4c3a-b730-f2382be0e329', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 49, 10, 462840, tzinfo=datetime.timezone.utc), 'ServiceName': 'PaymentService', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 2025-01-08 00:49:10 | BigQuery | New row: {'PUID': '45f6543e-298f-4c75-9771-26f1ccfeb726', 'Action': 'CREATE_PAYMENT', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 48, 58, 702891, tzinfo=datetime.timezone.utc), 'Status': 'SUCCESS', 'ServiceName': 'PaymentService', 'Metadata': {'amount': 100.5, 'currency': 'USD'}, 'RetryCount': 0, 'ErrorDetails': None, '_metadata_spanner_mod_type': 'INSERT', '_metadata_spanner_table_name': 'test_table', '_metadata_spanner_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 48, 59, 143983, tzinfo=datetime.timezone.utc), '_metadata_spanner_server_transaction_id': 'MTgzMjcwNzM5MTE3ODA3NjI4Mzc=', '_metadata_spanner_record_sequence': '00000000', '_metadata_spanner_is_last_record_in_transaction_in_partition': True, '_metadata_spanner_number_of_records_in_transaction': 1, '_metadata_spanner_number_of_partitions_in_transaction': 1, '_metadata_big_query_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 49, 3, 486262, tzinfo=datetime.timezone.utc), 'UserId': None, 'Source': None, 'TransactionId': None, 'Processed': None}  |
| 2025-01-08 00:49:05 | Spanner  | Inserted record: {'PUID': '119099ca-f106-40e2-83fb-aeadc48c6d3e', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 49, 4, 588023, tzinfo=datetime.timezone.utc), 'ServiceName': 'PaymentService', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| 2025-01-08 00:49:03 | BigQuery | New row: {'PUID': '42094c9d-f279-4a6f-930d-0ce2695ce7a2', 'Action': 'CREATE_PAYMENT', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 48, 52, 945627, tzinfo=datetime.timezone.utc), 'Status': 'SUCCESS', 'ServiceName': 'PaymentService', 'Metadata': {'amount': 100.5, 'currency': 'USD'}, 'RetryCount': 0, 'ErrorDetails': None, '_metadata_spanner_mod_type': 'INSERT', '_metadata_spanner_table_name': 'test_table', '_metadata_spanner_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 48, 53, 427135, tzinfo=datetime.timezone.utc), '_metadata_spanner_server_transaction_id': 'MTA3NDcyODk3MzM2ODc2ODgzMDc=', '_metadata_spanner_record_sequence': '00000000', '_metadata_spanner_is_last_record_in_transaction_in_partition': True, '_metadata_spanner_number_of_records_in_transaction': 1, '_metadata_spanner_number_of_partitions_in_transaction': 1, '_metadata_big_query_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 48, 57, 750561, tzinfo=datetime.timezone.utc), 'UserId': None, 'Source': None, 'TransactionId': None, 'Processed': None} |
| 2025-01-08 00:48:59 | Spanner  | Inserted record: {'PUID': '45f6543e-298f-4c75-9771-26f1ccfeb726', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 48, 58, 702891, tzinfo=datetime.timezone.utc), 'ServiceName': 'PaymentService', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 2025-01-08 00:48:57 | BigQuery | New row: {'PUID': 'fc6bdbee-e9ef-4384-8135-abc455e71d9b', 'Action': 'CREATE_PAYMENT', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 48, 47, 102520, tzinfo=datetime.timezone.utc), 'Status': 'SUCCESS', 'ServiceName': 'PaymentService', 'Metadata': {'amount': 100.5, 'currency': 'USD'}, 'RetryCount': 0, 'ErrorDetails': None, '_metadata_spanner_mod_type': 'INSERT', '_metadata_spanner_table_name': 'test_table', '_metadata_spanner_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 48, 47, 545855, tzinfo=datetime.timezone.utc), '_metadata_spanner_server_transaction_id': 'MTExMDUyNzk3OTk5NzQ3MDIwMzE=', '_metadata_spanner_record_sequence': '00000000', '_metadata_spanner_is_last_record_in_transaction_in_partition': True, '_metadata_spanner_number_of_records_in_transaction': 1, '_metadata_spanner_number_of_partitions_in_transaction': 1, '_metadata_big_query_commit_timestamp': datetime.datetime(2025, 1, 8, 0, 48, 51, 860739, tzinfo=datetime.timezone.utc), 'UserId': None, 'Source': None, 'TransactionId': None, 'Processed': None} |
| 2025-01-08 00:48:53 | Spanner  | Inserted record: {'PUID': '42094c9d-f279-4a6f-930d-0ce2695ce7a2', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 0, 48, 52, 945627, tzinfo=datetime.timezone.utc), 'ServiceName': 'PaymentService', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
+---------------------+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
ai-learningharshvardhan@harshvadhansAir payment-system % 


####


 % gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Payments ADD COLUMN Action STRING(100);"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Payments ADD COLUMN Metadata JSON;"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Payments ADD COLUMN RetryCount INT64;"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Payments ADD COLUMN ErrorDetails STRING(500);"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Payments ALTER COLUMN Timestamp SET NOT NULL;"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Payments ALTER COLUMN PaymentUID SET NOT NULL;"

Schema updating...done.                                                                                                                                     
Schema updating...done.                                                                                                                                     
Schema updating...done.                                                                                                                                     
Schema updating...done.                                                                                                                                     
ERROR: (gcloud.spanner.databases.ddl.update) INVALID_ARGUMENT: Error parsing Spanner DDL statement: ALTER TABLE Payments ALTER COLUMN Timestamp SET NOT NULL : SET NOT NULL not supported without column type.
ERROR: (gcloud.spanner.databases.ddl.update) INVALID_ARGUMENT: Error parsing Spanner DDL statement: ALTER TABLE Payments ALTER COLUMN PaymentUID SET NOT NULL : SET NOT NULL not supported without column type.
ai-learningharshvardhan@harshvadhansAir payment-system % gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Payments ALTER COLUMN Timestamp TIMESTAMP NOT NULL;"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Payments ALTER COLUMN PaymentUID STRING(36) NOT NULL;"

Schema updating...done.                                                                                                                                     
Schema updating...done.                                                                                                                                     
ai-learningharshvardhan@harshvadhansAir payment-system % 


gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Transactions ADD COLUMN Action STRING(100);"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Transactions ADD COLUMN Metadata JSON;"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Transactions ADD COLUMN RetryCount INT64;"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Transactions ADD COLUMN ErrorDetails STRING(500);"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Transactions ALTER COLUMN Timestamp TIMESTAMP NOT NULL;"

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE Transactions ALTER COLUMN PUID STRING(36) NOT NULL;"

###


IMPORTANT:

I delete the changestream on fly and re-created & below is the error

The error indicates that the partition_token used by the Dataflow job is invalid because it belongs to a previous version of the change stream (shared_audit_db_cs). This situation occurs when a change stream is dropped and recreated, as the old tokens become invalid.

To resolve the issue:

Steps to Fix the Issue
Stop and Restart the Dataflow Job:

Terminate the existing Dataflow job consuming the old partition_token.
Start a new Dataflow job to ensure it fetches fresh partition tokens from the newly created change stream.
Ensure Partition Tokens Are Refreshed:

By restarting the Dataflow job, it will query the Spanner change stream without the stale partition_token and obtain valid tokens for the new change stream.

resolve the issue with stale partition_token apart from deleting and recreating the Dataflow job. This is because the partition_token is directly tied to the previous change stream configuration, which is no longer valid after the change stream was recreated.

Here’s why this is the only solution:

Tokens Are Specific to a Change Stream:

When a change stream is created, it generates unique partition_tokens for its configuration.
If the change stream is dropped and recreated, the tokens from the previous configuration become invalid.
Dataflow Job Can't Reuse Old Tokens:

The Dataflow job uses the partition_token to know which partitions to read from.
Since the tokens no longer belong to a valid change stream, the job cannot function with the stale tokens.
Force Refreshing Tokens Is Not Supported:

There’s no option to manually refresh tokens for an existing Dataflow job without restarting it.



#############

Testing Plan for Change Stream Monitoring
Objective:
The goal is to validate the following:

Change Stream Behavior:
Ensure the change stream captures changes from a newly added table and streams the data into BigQuery.
Schema Compatibility:
Test how schema changes (adding/removing columns) in the source Spanner table affect the dataflow into BigQuery.
Data Consistency:
Confirm that data is streamed correctly under different schema configurations, and changes are reflected accurately in the BigQuery destination table.
Use Case Scenarios:
A new table is added to the Spanner database.
Data is pushed into the new table with the default schema.
The schema of the table is modified (adding a column).
Data is pushed with the modified schema.
The schema of the table is further modified (removing a column).
Data is pushed with the reduced schema.



Step 1: Add a New Table
Create a new table in Spanner (test_monitoring_table) with a schema identical to an existing table (test_table) that is working well with the current change stream.

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="CREATE TABLE test_monitoring_table (
      PUID STRING(36) NOT NULL,
      Action STRING(100) NOT NULL,
      Status STRING(50),
      Timestamp TIMESTAMP NOT NULL,
      ServiceName STRING(100),
      Metadata JSON,
      RetryCount INT64,
      ErrorDetails STRING(500)
    ) PRIMARY KEY (PUID);"


### Data published to DB & same updated in the BQ

 % python3 /Users/harshvardhan/Desktop/spanner-gke/gcp-npp/testing/end-to-end-testing.py
Starting Spanner and BigQuery demonstration...
Monitoring BigQuery table for real-time updates...
Polling BigQuery at 2025-01-08T05:21:53.984553+00:00...
[2025-01-08T05:22:01.989913+00:00] Logged to BigQuery: Spanner - Inserted record: {'PUID': 'cea13dbe-3322-4d91-bfa3-d26c88683325', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 22, 1, 235688, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
Inserted record into Spanner: {'PUID': 'cea13dbe-3322-4d91-bfa3-d26c88683325', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 22, 1, 235688, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
Polling BigQuery at 2025-01-08T05:22:06.781764+00:00...
[2025-01-08T05:22:07.625892+00:00] Logged to BigQuery: Spanner - Inserted record: {'PUID': 'ee8521de-1343-4a5d-9eb4-8b8dd59f5f25', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 22, 6, 994517, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}'_metadata_spanner_is_last_record_in_transaction_in_partition': True, '_metadata_spanner_number_of_records_in_transaction': 1, '_metadata_spanner_number_of_partitions_in_transaction': 1, '_metadata_big_query_commit_timestamp': datetime.datetime(2025, 1, 8, 5, 18, 8, 287326, tzinfo=datetime.timezone.utc), 'UserId': None, 'Source': None, 'TransactionId': None, 'Processed': None}

'
% bq query --use_legacy_sql=false \
"SELECT *
 FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`
 WHERE PUID = 'ee8521de-1343-4a5d-9eb4-8b8dd59f5f25'"

+--------------------------------------+----------------+---------------------+---------+--------------+-----------------------------------+------------+--------------+----------------------------+------------------------------+------------------------------------+-----------------------------------------+-----------------------------------+--------------------------------------------------------------+----------------------------------------------------+-------------------------------------------------------+--------------------------------------+--------+--------+---------------+-----------+
|                 PUID                 |     Action     |      Timestamp      | Status  | ServiceName  |             Metadata              | RetryCount | ErrorDetails | _metadata_spanner_mod_type | _metadata_spanner_table_name | _metadata_spanner_commit_timestamp | _metadata_spanner_server_transaction_id | _metadata_spanner_record_sequence | _metadata_spanner_is_last_record_in_transaction_in_partition | _metadata_spanner_number_of_records_in_transaction | _metadata_spanner_number_of_partitions_in_transaction | _metadata_big_query_commit_timestamp | UserId | Source | TransactionId | Processed |
+--------------------------------------+----------------+---------------------+---------+--------------+-----------------------------------+------------+--------------+----------------------------+------------------------------+------------------------------------+-----------------------------------------+-----------------------------------+--------------------------------------------------------------+----------------------------------------------------+-------------------------------------------------------+--------------------------------------+--------+--------+---------------+-----------+
| ee8521de-1343-4a5d-9eb4-8b8dd59f5f25 | CREATE_PAYMENT | 2025-01-08 05:22:06 | SUCCESS | Test-service | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_monitoring_table        |                2025-01-08 05:22:07 | Mzk2ODY1NTk3MTkwMzkzODIzNA==            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 05:22:13 | NULL   | NULL   | NULL          |      NULL |
+--------------------------------------+----------------+---------------------+---------+--------------+-----------------------------------+------------+--------------+----------------------------+------------------------------+------------------------------------+-----------------------------------------+-----------------------------------+--------------------------------------------------------------+----------------------------------------------------+-------------------------------------------------------+--------------------------------------+--------+--------+---------------+-----------+
ai-learningharshvardhan@harshvadhansAir payment-system % 



######

Next Step: Adding a new column to table `test_monitoring_table` & this is not there in BQ table:

gcloud spanner databases ddl update shared-db \
  --instance=sample-instance \
  --ddl="ALTER TABLE test_monitoring_table ADD COLUMN DataSource STRING(100);"

Verify Schema Update:

 % gcloud spanner databases execute-sql shared-db \
  --instance=sample-instance \
  --sql="SELECT COLUMN_NAME, SPANNER_TYPE, IS_NULLABLE
         FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_NAME = 'test_monitoring_table';"

COLUMN_NAME   SPANNER_TYPE  IS_NULLABLE
PUID          STRING(36)    NO
Action        STRING(100)   NO
Status        STRING(50)    YES
Timestamp     TIMESTAMP     NO
ServiceName   STRING(100)   YES
Metadata      JSON          YES
RetryCount    INT64         YES
ErrorDetails  STRING(500)   YES
DataSource    STRING(100)   YES


Important: Before Inserting new data, supporting same schema, Streaming working fine:

  sample_data = {
            "PUID": str(uuid.uuid4()),
            "Action": "CREATE_PAYMENT",
            "Status": "SUCCESS",
            "Timestamp": datetime.now(timezone.utc),
            "ServiceName": "Test-service",
            "Metadata": '{"amount": 100.50, "currency": "USD"}',
            "RetryCount": 0,
            "ErrorDetails": None,
        }

SECNERIO -2 

Important: Lets add data with new column & see the result:

Result: As we see, data is not getting writtern to BQ table with:


Inserted record into Spanner: {'PUID': 'fdbf4870-fd4c-464f-a5fc-9f6e48c8a8fc', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 43, 35, 317837, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'DataSource': 'InderBank', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
No new rows found at 2025-01-08T05:43:36.111413+00:00.
Polling BigQuery at 2025-01-08T05:43:41.111658+00:00...

 bq query --nouse_legacy_sql "SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"                                
  
+------------+
| total_rows |
+------------+
|       6267 |
+------------+

% python3 /Users/harshvardhan/Desktop/spanner-gke/gcp-npp/testing/end-to-end-testing.py
Starting Spanner and BigQuery demonstration...
Monitoring BigQuery table for real-time updates...
Polling BigQuery at 2025-01-08T05:43:28.214726+00:00...
No new rows found at 2025-01-08T05:43:29.994612+00:00.
[2025-01-08T05:43:30.316452+00:00] Logged to BigQuery: Spanner - Inserted record: {'PUID': '1bedf503-a22c-4e9e-a4ba-ff3a3dbb0ba0', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 43, 28, 214008, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'DataSource': 'InderBank', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
Inserted record into Spanner: {'PUID': '1bedf503-a22c-4e9e-a4ba-ff3a3dbb0ba0', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 43, 28, 214008, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'DataSource': 'InderBank', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
Polling BigQuery at 2025-01-08T05:43:34.999433+00:00...
[2025-01-08T05:43:35.976446+00:00] Logged to BigQuery: Spanner - Inserted record: {'PUID': 'fdbf4870-fd4c-464f-a5fc-9f6e48c8a8fc', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 43, 35, 317837, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'DataSource': 'InderBank', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
Inserted record into Spanner: {'PUID': 'fdbf4870-fd4c-464f-a5fc-9f6e48c8a8fc', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 43, 35, 317837, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'DataSource': 'InderBank', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
No new rows found at 2025-01-08T05:43:36.111413+00:00.
Polling BigQuery at 2025-01-08T05:43:41.111658+00:00...
[2025-01-08T05:43:41.645271+00:00] Logged to BigQuery: Spanner - Inserted record: {'PUID': '46ca103d-5c9f-49a1-93bf-0b8c25a6d060', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 43, 40, 981583, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'DataSource': 'InderBank', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
Inserted record into Spanner: {'PUID': '46ca103d-5c9f-49a1-93bf-0b8c25a6d060', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 5, 43, 40, 981583, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'DataSource': 'InderBank', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
No new rows found at 2025-01-08T05:43:42.234006+00:00.
Polling BigQuery at 2025-01-08T05:43:47.236686+00:00...


##########

% gsutil ls gs://dataflow-temp-spanner-bq-shared-db/temp/

gs://dataflow-temp-spanner-bq-shared-db/temp/dlq/
gs://dataflow-temp-spanner-bq-shared-db/temp/dlq/
zsh: no such file or directory: gs://dataflow-temp-spanner-bq-shared-db/temp/dlq/
ai-learningharshvardhan@harshvadhansAir payment-system % gsutil ls gs://dataflow-temp-spanner-bq-shared-db/temp/dlq/
gs://dataflow-temp-spanner-bq-shared-db/temp/dlq/retry/


% gsutil cp gs://dataflow-temp-spanner-bq-shared-db/temp/dlq/severe/2025/01/08/05/59/error-pane-0-last-00019-of-00020.json .

      "Watermark": {
        "name": "Watermark",
        "type": {
          "code": "{\"code\":\"TIMESTAMP\"}"
        },
        "isPrimaryKey": false,
        "ordinalPosition": 7
      }
    },
    "_metadata_error": {
      "errors": [
        {
          "debugInfo": "",
          "location": "PartitionToken",
          "message": "no such field: PartitionToken.",
          "reason": "invalid"
        }
      ],
      "index": 7
    },
    "_metadata_retry_count": 6
  },
  "error_message": null
}

Understand the Categories
Retry (retry/): Contains records that may fail due to temporary issues (e.g., transient errors or service unavailability). These records are typically eligible for reprocessing.
Severe (severe/): Contains records that fail due to critical issues like schema mismatches, invalid data, or type incompatibility. These often need manual intervention.


General Rule: For a seamless Dataflow job, ensure that:

The BigQuery table schema aligns with the schema of the monitored Spanner table.
Newly added columns in Spanner are also added to BigQuery.


####

FIX:

Adding the missing column in bigquery table:

Before:

% bq show --schema --format=prettyjson spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog | jq -r '.[] | [.name, .type, .mode] | @tsv' | column -t -s$'\t'

PUID                                                          STRING
Action                                                        STRING
Timestamp                                                     TIMESTAMP
Status                                                        STRING
ServiceName                                                   STRING
Metadata                                                      JSON
RetryCount                                                    INTEGER
ErrorDetails                                                  STRING
_metadata_spanner_mod_type                                    STRING
_metadata_spanner_table_name                                  STRING
_metadata_spanner_commit_timestamp                            TIMESTAMP
_metadata_spanner_server_transaction_id                       STRING
_metadata_spanner_record_sequence                             STRING
_metadata_spanner_is_last_record_in_transaction_in_partition  BOOLEAN
_metadata_spanner_number_of_records_in_transaction            INTEGER
_metadata_spanner_number_of_partitions_in_transaction         INTEGER
_metadata_big_query_commit_timestamp                          TIMESTAMP
UserId                                                        STRING
Source                                                        STRING
TransactionId                                                 STRING
Processed                                                     BOOLEAN
ai-learningharshvardhan@harshvadhansAir payment-system % 

After:

ALTER TABLE `spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog`
ADD COLUMN DataSource STRING;

% bq show --schema --format=prettyjson spanner-gke-443910:audit_service_dataset.payment_audit_trail_changelog | jq -r '.[] | [.name, .type, .mode] | @tsv' | column -t -s$'\t'
  
PUID                                                          STRING
Action                                                        STRING
Timestamp                                                     TIMESTAMP
Status                                                        STRING
ServiceName                                                   STRING
Metadata                                                      JSON
RetryCount                                                    INTEGER
ErrorDetails                                                  STRING
_metadata_spanner_mod_type                                    STRING
_metadata_spanner_table_name                                  STRING
_metadata_spanner_commit_timestamp                            TIMESTAMP
_metadata_spanner_server_transaction_id                       STRING
_metadata_spanner_record_sequence                             STRING
_metadata_spanner_is_last_record_in_transaction_in_partition  BOOLEAN
_metadata_spanner_number_of_records_in_transaction            INTEGER
_metadata_spanner_number_of_partitions_in_transaction         INTEGER
_metadata_big_query_commit_timestamp                          TIMESTAMP
UserId                                                        STRING
Source                                                        STRING
TransactionId                                                 STRING
Processed                                                     BOOLEAN
DataSource                                                    STRING


######


ai-learningharshvardhan@harshvadhansAir payment-system % bq query --nouse_legacy_sql "SELECT COUNT(*) AS total_rows FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\`"

+------------+
| total_rows |
+------------+
|       6286 |
+------------+

[2025-01-08T06:17:07.243305+00:00] Logged to BigQuery: Spanner - Inserted record: {'PUID': '7aaaf7c9-8bb8-4cfb-96f4-8cbe046a658d', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 6, 17, 6, 461044, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'DataSource': 'InderBank', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
Inserted record into Spanner: {'PUID': '7aaaf7c9-8bb8-4cfb-96f4-8cbe046a658d', 'Action': 'CREATE_PAYMENT', 'Status': 'SUCCESS', 'Timestamp': datetime.datetime(2025, 1, 8, 6, 17, 6, 461044, tzinfo=datetime.timezone.utc), 'ServiceName': 'Test-service', 'DataSource': 'InderBank', 'Metadata': '{"amount": 100.50, "currency": "USD"}', 'RetryCount': 0, 'ErrorDetails': None}
Polling BigQuery at 2025-01-08T06:17:07.537007+00:00...


CONCLUSION: After adding the new column, system automatically recovered.


Next secnerio:

What happend, if any  on a diffrent, where this column is not present & if some data got inserted ?


% bq query --use_legacy_sql=false \
"SELECT * FROM \`spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog\` WHERE PUID = '2a5f7d4c-0d98-4ef6-81d8-b1e92abe020b';"

+--------------------------------------+----------------+---------------------+---------+--------------+-----------------------------------+------------+--------------+----------------------------+------------------------------+------------------------------------+-----------------------------------------+-----------------------------------+--------------------------------------------------------------+----------------------------------------------------+-------------------------------------------------------+--------------------------------------+--------+--------+---------------+-----------+------------+
|                 PUID                 |     Action     |      Timestamp      | Status  | ServiceName  |             Metadata              | RetryCount | ErrorDetails | _metadata_spanner_mod_type | _metadata_spanner_table_name | _metadata_spanner_commit_timestamp | _metadata_spanner_server_transaction_id | _metadata_spanner_record_sequence | _metadata_spanner_is_last_record_in_transaction_in_partition | _metadata_spanner_number_of_records_in_transaction | _metadata_spanner_number_of_partitions_in_transaction | _metadata_big_query_commit_timestamp | UserId | Source | TransactionId | Processed | DataSource |
+--------------------------------------+----------------+---------------------+---------+--------------+-----------------------------------+------------+--------------+----------------------------+------------------------------+------------------------------------+-----------------------------------------+-----------------------------------+--------------------------------------------------------------+----------------------------------------------------+-------------------------------------------------------+--------------------------------------+--------+--------+---------------+-----------+------------+
| 2a5f7d4c-0d98-4ef6-81d8-b1e92abe020b | CREATE_PAYMENT | 2025-01-08 06:44:08 | SUCCESS | Test-service | {"amount":100.5,"currency":"USD"} |          0 | NULL         | INSERT                     | test_table                   |                2025-01-08 06:44:09 | MTIwMTYwMjMzNjQ3OTU2MjgzMDE=            | 00000000                          |                                                         true |                                                  1 |                                                     1 |                  2025-01-08 06:44:11 | NULL   | NULL   | NULL          |      NULL | NULL       |
+--------------------------------------+----------------+---------------------+---------+--------------+-----------------------------------+------------+--------------+----------------------------+------------------------------+------------------------------------+-----------------------------------------+-----------------------------------+--------------------------------------------------------------+----------------------------------------------------+-------------------------------------------------------+--------------------------------------+--------+--------+---------------+-----------+------------+
ai-learningharshvardhan@harshvadhansAir payment-system % 

PUID	Action	Timestamp	Status	ServiceName	Metadata	RetryCount	ErrorDetails	_metadata_spanner_mod_type	_metadata_spanner_table_name	_metadata_spanner_commit_timestamp	_metadata_spanner_server_transaction_id	_metadata_spanner_record_sequence	_metadata_spanner_is_last_record_in_transaction_in_partition	_metadata_spanner_number_of_records_in_transaction	_metadata_spanner_number_of_partitions_in_transaction	_metadata_big_query_commit_timestamp	UserId	Source	TransactionId	Processed	DataSource
2a5f7d4c-0d98-4ef6-81d8-b1e92abe020b	CREATE_PAYMENT	2025-01-08 06:44:08.727888 UTC	SUCCESS	Test-service	{"amount":100.5,"currency":"USD"}	0		INSERT	test_table	2025-01-08 06:44:09.103839 UTC	MTIwMTYwMjMzNjQ3OTU2MjgzMDE=	0	TRUE	1	1	2025-01-08 06:44:11.458576 UTC					

SELECT 
    puld, 
    puidHash, 
    messagePayload, 
    createTimestamp, 
    updatedTimestamp, 
    processingNode, 
    currentState, 
    paymentNotes, 
    PaymentStatus
FROM 
    `spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog`
WHERE 
    puld = '55ca3a01-aaed-40';  -- Replace with the PUID you want to search for


SELECT 
    puld, 
    puidHash, 
    JSON_EXTRACT(messagePayload, '$.Header') AS Header,
    JSON_EXTRACT(messagePayload, '$.Body') AS Body,
    JSON_EXTRACT(messagePayload, '$.Trailer') AS Trailer,
    JSON_EXTRACT(messagePayload, '$.FinalStage') AS FinalStage,
    JSON_EXTRACT(messagePayload, '$.Audit') AS Audit
FROM 
    `spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog`
WHERE 
    puld = '55ca3a01-aaed-40';  -- Replace with your search criteria



puld
puidHash
Header
Body
Trailer
FinalStage
Audit
1	
55ca3a01-aaed-40
82049977ce86286d670b676ba9f02e7f
{"puid":"55ca3a01-aaed-40","stage":1,"timestamp":"2025-01-10T00:28:06.220534+00:00"}
{"details":"Payment in progress","puid":"55ca3a01-aaed-40","stage":2}
{"additional_info":"Payment successfully completed","puid":"55ca3a01-aaed-40","stage":3,"status":"Completed"}
{"puid":"55ca3a01-aaed-40","stage":4,"status":"Final"}
{"audit_timestamp":"2025-01-10T00:28:06.220564+00:00","puid":"55ca3a01-aaed-40","stage":5}
2	
55ca3a01-aaed-40
82049977ce86286d670b676ba9f02e7f
{"puid":"55ca3a01-aaed-40","stage":1,"timestamp":"2025-01-10T00:28:06.220534+00:00"}
{"details":"Payment in progress","puid":"55ca3a01-aaed-40","stage":2}
{"additional_info":"Payment successfully completed","puid":"55ca3a01-aaed-40","stage":3,"status":"Completed"}
{"puid":"55ca3a01-aaed-40","stage":4,"status":"Final"}
{"audit_timestamp":"2025-01-10T00:28:06.220564+00:00","puid":"55ca3a01-aaed-40","stage":5}





####

**USECASE - JSON PAYLOAD**

Single Entry per PUID:

There will be only one row per PUID in the Spanner table. The puid is a unique identifier for each payment transaction.

Incremental Updates to messagePayload:

The messagePayload column will be updated dynamically as each stage completes. This means:

- For each payment, we start with an empty JSON structure.
- As each stage (1 through 5) completes, the relevant part of the JSON structure (such as Header, Body, Trailer, RiskAssessment, FinalStage) gets updated, and new information is added to the messagePayload.
- By the end of the payment processing, the messagePayload will contain all the necessary details for each stage.

FAT-Message Structure (Wrapper):

- FAT (Fully-Available-Transaction) Wrapper: The messagePayload is designed to have a structured hierarchy with all the stages of the transaction encapsulated within it.

- The messagePayload will include a trailer that summarizes or flags important information from the previous stages (like transaction status).

- At each stage, new data is added as a key-value pair in the existing JSON object, ensuring it grows progressively as the payment moves through different stages (e.g., payment initialization, fraud check, risk assessment, payment completion, audit).

Example of Final messagePayload:

For a single PUID, by the time the payment is processed through all 5 stages, the resulting messagePayload in Spanner would look something like this:

{
  "Header": {
    "puid": "32bcfcab-dbf2-4b",
    "timestamp": "2025-01-10T09:51:04.916168+00:00",
    "stage": 1,
    "transactionId": "f63fa329-0d3e-431a-87d4-46db916ea0a3"
  },
  "Body": {
    "puid": "32bcfcab-dbf2-4b",
    "stage": 2,
    "details": "Payment initialized",
    "amount": 100.0,
    "currency": "USD",
    "paymentType": "Domestic Transfer"
  },
  "Trailer": {
    "puid": "32bcfcab-dbf2-4b",
    "stage": 3,
    "status": "Payment in progress",
    "additional_info": "Payment stage 1 completed"
  },
  "RiskAssessment": {
    "puid": "32bcfcab-dbf2-4b",
    "stage": 4,
    "fraudCheck": true,
    "fraudStatus": "Flagged",
    "chargebackStatus": "None"
  },
  "FinalStage": {
    "puid": "32bcfcab-dbf2-4b",
    "stage": 5,
    "status": "Final",
    "settlementAmount": 97.5,
    "settlementStatus": "Completed"
  }
}

Key Points:

- Single Row per PUID: The PUID is the key identifier, and only one row will be created for each payment in the Spanner table.
- Progressive Updates: The messagePayload will keep getting updated as the payment moves through stages.
- FAT Wrapper Structure: The messagePayload will maintain the full structure throughout all stages, with each stage being added as a nested part of the JSON object.




% bq query --use_legacy_sql=false 'SELECT puid, messagePayload FROM `spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog` WHERE puid = "21988a1d-548c-4b" ORDER BY Timestamp DESC LIMIT 10'

+------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|       puid       |                                                                                                                                                                                                                                                                                                                                                                                                                                                                         messagePayload                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
+------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 21988a1d-548c-4b | {"Audit":{"actionDetails":"Transaction initiated, processed, and completed successfully","audit_timestamp":"2025-01-10T15:22:39.591071+00:00","internalComments":"No issues during processing","operatorId":"op987","puid":"21988a1d-548c-4b","stage":6,"userId":"user123"},"Body":{"amount":100,"currency":"USD","details":"Payment initiated","paymentType":"Domestic Transfer","puid":"21988a1d-548c-4b","stage":2},"FinalStage":{"puid":"21988a1d-548c-4b","settlementAmount":97.5,"settlementStatus":"Completed","stage":5,"status":"Final"},"Header":{"puid":"21988a1d-548c-4b","stage":1,"timestamp":"2025-01-10T15:22:39.590973+00:00","transactionId":"821d2111-3f68-4b38-96e4-c6955e8d4dc5"},"RiskAssessment":{"chargebackStatus":"None","fraudCheck":true,"fraudStatus":"Flagged","puid":"21988a1d-548c-4b","stage":4},"Trailer":{"additional_info":"Payment stage 1 completed","puid":"21988a1d-548c-4b","stage":3,"status":"Payment in progress"}} |
+------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
ai-learningharshvardhan@harshvadhansAir payment-system % 




-- Equvalent BQ SQL Query:

SELECT puid, TO_JSON_STRING(messagePayload) AS messagePayload
FROM `spanner-gke-443910.audit_service_dataset.payment_audit_trail_changelog`
WHERE puid = "21988a1d-548c-4b"
ORDER BY Timestamp DESC
LIMIT 10;

[{
  "puid": "21988a1d-548c-4b",
  "messagePayload": "{\"Audit\":{\"actionDetails\":\"Transaction initiated, processed, and completed successfully\",\"audit_timestamp\":\"2025-01-10T15:22:39.591071+00:00\",\"internalComments\":\"No issues during processing\",\"operatorId\":\"op987\",\"puid\":\"21988a1d-548c-4b\",\"stage\":6,\"userId\":\"user123\"},\"Body\":{\"amount\":100,\"currency\":\"USD\",\"details\":\"Payment initiated\",\"paymentType\":\"Domestic Transfer\",\"puid\":\"21988a1d-548c-4b\",\"stage\":2},\"FinalStage\":{\"puid\":\"21988a1d-548c-4b\",\"settlementAmount\":97.5,\"settlementStatus\":\"Completed\",\"stage\":5,\"status\":\"Final\"},\"Header\":{\"puid\":\"21988a1d-548c-4b\",\"stage\":1,\"timestamp\":\"2025-01-10T15:22:39.590973+00:00\",\"transactionId\":\"821d2111-3f68-4b38-96e4-c6955e8d4dc5\"},\"RiskAssessment\":{\"chargebackStatus\":\"None\",\"fraudCheck\":true,\"fraudStatus\":\"Flagged\",\"puid\":\"21988a1d-548c-4b\",\"stage\":4},\"Trailer\":{\"additional_info\":\"Payment stage 1 completed\",\"puid\":\"21988a1d-548c-4b\",\"stage\":3,\"status\":\"Payment in progress\"}}"
}]


-- **LIMITATION with bq studio**

- The RESULT, don't show-up with complete output but only show last stage 
- Question: Is there any limits on max characters to be showcases ?


---- IN SPANNER ----

SELECT * FROM PaymentMilestoneEvents WHERE puid = '21988a1d-548c-4b';


puid
puidHash
messagePayload
createTimestamp
updatedTimestamp
processingNode
currentState
paymentNotes
PaymentStatus
21988a1d-548c-4b
2037a109ed6f1bf48bf7d7cdf651a109
{"Audit":{"actionDetails":"Transaction initiated, processed, and completed successfully","audit_timestamp":"2025-01-10T15:22:39.591071+00:00","internalComments":"No issues during processing","operatorId":"op987","puid":"21988a1d-548c-4b","stage":6,"userId":"user123"},"Body":{"amount":100.0,"currency":"USD","details":"Payment initiated","paymentType":"Domestic Transfer","puid":"21988a1d-548c-4b","stage":2},"FinalStage":{"puid":"21988a1d-548c-4b","settlementAmount":97.5,"settlementStatus":"Completed","stage":5,"status":"Final"},"Header":{"puid":"21988a1d-548c-4b","stage":1,"timestamp":"2025-01-10T15:22:39.590973+00:00","transactionId":"821d2111-3f68-4b38-96e4-c6955e8d4dc5"},"RiskAssessment":{"chargebackStatus":"None","fraudCheck":true,"fraudStatus":"Flagged","puid":"21988a1d-548c-4b","stage":4},"Trailer":{"additional_info":"Payment stage 1 completed","puid":"21988a1d-548c-4b","stage":3,"status":"Payment in progress"}}
2025-01-10T15:22:39.591331Z
2025-01-10T15:22:39.591332Z
Node1
INITIAL
First payment of the day
SUCCESS

#####

JOB's
Dataflow:
Destroy

 % gcloud builds submit \
    --config=cloudbuild.yaml \
    --substitutions=_PIPELINE=dataflow,_DATAFLOW_PIPELINE=spanner-to-pubsub,_ACTION=destroy,_ENV=dev \
    --service-account="projects/spanner-gke-443910/serviceAccounts/cloudbuild-cicd@spanner-gke-443910.iam.gserviceaccount.com" \
    --gcs-log-dir="gs://cloud-build-logs-spanner-gke-443910"

Apply:

 gcloud builds submit \
    --config=cloudbuild.yaml \
    --substitutions=_PIPELINE=dataflow,_DATAFLOW_PIPELINE=spanner-to-pubsub,_ACTION=apply,_ENV=dev \
    --service-account="projects/spanner-gke-443910/serviceAccounts/cloudbuild-cicd@spanner-gke-443910.iam.gserviceaccount.com" \
    --gcs-log-dir="gs://cloud-build-logs-spanner-gke-443910"




Usecase: 

--> Spanner to Pub/Sub

The issue arises because the Spanner_Change_Streams_to_PubSub Dataflow job template and its counterpart PubSub_to_BigQuery_Flex are not designed to handle or transform Spanner change stream events into the original row format as stored in Spanner. Instead, they work with change event data emitted by Spanner's change stream feature.

Key Points About Spanner Change Streams
What Change Streams Emit:

Spanner change streams emit change events that represent modifications (inserts, updates, or deletes) to rows in a Spanner table.
The emitted event structure contains:
mods: A list of changes (keysJson, newValuesJson, oldValuesJson).
modType: Type of modification (INSERT, UPDATE, DELETE).
Metadata such as commit timestamps, partition tokens, and transaction details.


Below Event Example::

{
  "mods": [
    {
      "keysJson": "{\"puid\":\"ba76a577-3183-4f\"}",
      "newValuesJson": "{\"puid\":\"ba76a577-3183-4f\",\"messagePayload\":\"{...}\",...}",
      "oldValuesJson": "{\"puid\":\"ba76a577-3183-4f\",\"messagePayload\":\"{...}\",...}"
    }
  ],
  "modType": "UPDATE",
  "metadata": {
    "commitTimestamp": "2025-01-13T13:33:17.802943+00:00",
    ...
  }
}

The original row content is embedded within newValuesJson.

In Spanner:


% python3 /Users/harshvardhan/Desktop/spanner-gke/gcp-npp/testing/spanner-pubsub-testing-1payload.py
2025-01-14 00:33:19,637 - INFO - Inserted record into Spanner: {'puid': '7c554e39-7a33-40', 'puidHash': 'de933dd142f717e7d7632063f0f918e4', 'messagePayload': '{"Header": {"puid": "7c554e39-7a33-40", "timestamp": "2025-01-13T13:33:17.802943+00:00", "stage": 1, "transactionId": "def0fbcd-2e92-48e4-aa67-95dbb023a455"}, "Body": {"puid": "7c554e39-7a33-40", "stage": 2, "details": "Payment initiated", "amount": 100.0, "currency": "USD", "paymentType": "Domestic Transfer"}, "Trailer": {"puid": "7c554e39-7a33-40", "stage": 3, "status": "Payment in progress", "additional_info": "Payment stage 1 completed"}, "RiskAssessment": {"puid": "7c554e39-7a33-40", "stage": 4, "fraudCheck": true, "fraudStatus": "Flagged", "chargebackStatus": "None"}, "FinalStage": {"puid": "7c554e39-7a33-40", "stage": 5, "status": "Final", "settlementAmount": 97.5, "settlementStatus": "Completed"}, "Audit": {"puid": "7c554e39-7a33-40", "stage": 6, "audit_timestamp": "2025-01-13T13:33:17.802972+00:00", "userId": "user123", "operatorId": "op987", "actionDetails": "Transaction initiated, processed, and completed successfully", "internalComments": "No issues during processing"}}', 'createTimestamp': datetime.datetime(2025, 1, 13, 13, 33, 17, 803015, tzinfo=datetime.timezone.utc), 'updatedTimestamp': datetime.datetime(2025, 1, 13, 13, 33, 17, 803016, tzinfo=datetime.timezone.utc), 'processingNode': 'Node1', 'currentState': 'INITIAL', 'paymentNotes': 'Single record for Pub/Sub testing', 'PaymentStatus': 'SUCCESS'}
2025-01-14 00:33:20,501 - INFO - Published message to Pub/Sub topic: 13532448093075977


In Pub/Sub

% gcloud pubsub subscriptions pull spanner-change-streams-subscription --limit=1 --auto-ack

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────                                                                                                                                                                                              DATA                                                                                                                                                                                                                                                                                                                          │     MESSAGE_ID    │ ORDERING_KEY │ ATTRIBUTES │ DELIVERY_ATTEMPT │ ACK_STATUS │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│ {"partitionToken":"__8BAYEHAc4hd3AAAYLAy4NzaGFyZWRfYXVkaXRfZGJfY3MAAYSBBgL64BACgoKAgwjDZAAAAAAAAIQEL66Ml4VnNjQyXzMxMjQ3MzcAAf__hf8GK5YbggtMhv8GK5aDOASIh4DAZAEB__8","commitTimestamp":{"seconds":1736774851,"nanos":908207000},"serverTransactionId":"MzExNTkwMzQ3OTIwMTMzOTAwMg==","isLastRecordInTransactionInPartition":true,"recordSequence":"00000000","tableName":"Metadata_shared_db_bccdb8d6_3d49_46ea_ad38_18aa016d18c3","rowType":[{"name":"PartitionToken","type":{"code":"{\"code\":\"STRING\"}"},"isPrimaryKey":true,"ordinalPosition":1},{"name":"Watermark","type":{"code":"{\"code\":\"TIMESTAMP\"}"},"isPrimaryKey":false,"ordinalPosition":7}],"mods":[{"keysJson":"{\"PartitionToken\":\"__8BAYEHAc4hd3AAAYLAy4NzaGFyZWRfYXVkaXRfZGJfY3MAAYSBAIKAgwjDZAAAAAAB3YQEHbHBFIVnMF8wAAH__4X_BiuWEU-l2Yb_BiuWbshD8Yf_BiuWEU-l2cBkAQH__w\"}","oldValuesJson":"{\"Watermark\":\"2025-01-13T13:27:22.821Z\"}","newValuesJson":"{\"Watermark\":\"2025-01-13T13:27:29.655Z\"}"}],"modType":"UPDATE","valueCaptureType":"OLD_AND_NEW_VALUES","numberOfRecordsInTransaction":1,"numberOfPartitionsInTransaction":1,"transactionTag":"updateWatermark","isSystemTransaction":false,"metadata":{"partitionToken":"__8BAYEHAc4hd3AAAYLAy4NzaGFyZWRfYXVkaXRfZGJfY3MAAYSBBgL64BACgoKAgwjDZAAAAAAAAIQEL66Ml4VnNjQyXzMxMjQ3MzcAAf__hf8GK5YbggtMhv8GK5aDOASIh4DAZAEB__8","recordTimestamp":{"seconds":1736774851,"nanos":908207000},"partitionStartTimestamp":{"seconds":1736773566,"nanos":860108000},"partitionEndTimestamp":{"seconds":253402300799,"nanos":999999998},"partitionCreatedAt":{"seconds":1736773566,"nanos":914175000},"partitionScheduledAt":{"seconds":1736773567,"nanos":497039000},"partitionRunningAt":{"seconds":1736773567,"nanos":515199000},"queryStartedAt":{"seconds":-62135596800,"nanos":0},"recordStreamStartedAt":{"seconds":1736774852,"nanos":694000000},"recordStreamEndedAt":{"seconds":1736774852,"nanos":705000000},"recordReadAt":{"seconds":-62135596800,"nanos":0},"totalStreamTimeMillis":11,"numberOfRecordsRead":1}} │ 13528616349436161 │              │            │                  │ SUCCESS    │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴───────────────────┴──────────────┴────────────┴──────────────────┴────────────┘
(venv) ai-learningharshvardhan@harshvadhansAir terraform % 


1. Spanner Change Streams to Pub/Sub Template

Feature:

Publishes raw Spanner change stream events to a Pub/Sub topic.
Includes metadata, transaction details, and the mods array containing the actual changes.

Limitation:

It does not extract the row data from newValuesJson or reconstruct the original row format.
Downstream systems receive complex change event data instead of a plain representation of the original row.


2. Pub/Sub to BigQuery Template

Feature:

Reads messages from a Pub/Sub topic and writes them to BigQuery.
Allows you to specify:
The target BigQuery table (outputTableSpec).
A Dead Letter Queue (DLQ) for failed messages (outputDeadletterTable).
Supports JSON transformation via custom JavaScript UDFs.

Limitation:


It assumes that the incoming messages are in the final format required by the BigQuery schema.
Does not natively parse or transform Spanner change events to extract newValuesJson for insertion.



What's Going Wrong

Event Format Mismatch:

Spanner emits change events with nested structures (e.g., mods).
The PubSub_to_BigQuery template expects plain JSON rows compatible with the target BigQuery table schema.
As a result, raw Spanner change events fail the transformation and validation steps in the PubSub_to_BigQuery template.


Dead Letter Queue (DLQ) Usage:

Since the raw event format is incompatible, many messages are redirected to the DLQ.
This indicates that the pipeline is failing to process messages due to schema mismatches or transformation issues.

