# Apache NiFi System Performance Monitoring

This repository provides tools to visualize Apache NiFi system performance using Elasticsearch and Kibana.

## Architecture

<img width="507" height="761" alt="apache_nifi_elasticsearch" src="https://github.com/user-attachments/assets/344cb312-3a8a-48ff-9ffb-735c7350224f" />

## Components

### MonitoringHeartbeat.json

A NiFi flow template that:
- Reads NiFi log files from `/var/log/nifi`
- Extracts timestamp and latency metrics from heartbeat logs
- Transforms data to JSON format
- Indexes the data into Elasticsearch (`nifi_heartbeat_v3` index)

### kibana-dashboard.ndjson

A Kibana dashboard export file for visualizing NiFi system performance. The dashboard includes:

- **NiFi Latency Over Time**: Line chart showing average latency trends
- **NiFi Max Latency**: Metric displaying maximum recorded latency
- **NiFi Min Latency**: Metric displaying minimum recorded latency
- **NiFi Avg Latency**: Metric displaying average latency
- **NiFi Heartbeat Count**: Total count of heartbeat records
- **NiFi Latency Distribution**: Histogram showing latency distribution

## Setup Instructions

### 1. Import NiFi Flow

1. Open Apache NiFi web interface
2. Right-click on the canvas and select "Upload Template"
3. Upload `MonitoringHeartbeat.json`
4. Drag the template onto the canvas
5. Configure the Elasticsearch URL in the `PutElasticsearchHttp` processor
6. Start all processors

### 2. Import Kibana Dashboard

1. Open Kibana web interface
2. Navigate to **Stack Management** > **Saved Objects**
3. Click **Import**
4. Select the `kibana-dashboard.ndjson` file
5. Click **Import** to complete the process
6. Navigate to **Dashboards** and open "Apache NiFi System Performance"

## Requirements

- Apache NiFi 1.23.2+
- Elasticsearch 7.x or 8.x
- Kibana 7.x or 8.x
