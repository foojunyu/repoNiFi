# NiFi Performance Monitoring - Project Documentation

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Project Timeline](#project-timeline)
3. [Architecture Overview](#architecture-overview)
4. [Features](#features)
5. [Installation Guide](#installation-guide)
6. [Configuration Guide](#configuration-guide)
7. [Dashboard Guide](#dashboard-guide)
8. [Alert Configuration](#alert-configuration)
9. [Performance Optimization](#performance-optimization)
10. [Troubleshooting](#troubleshooting)

---

## Executive Summary

This project provides a comprehensive monitoring solution for Apache NiFi 1.23.2 integrated with Elasticsearch Cloud and Kibana. The solution collects, stores, and visualizes NiFi performance metrics to enable proactive monitoring, alerting, and trend analysis.

### Key Capabilities

| Category | Metrics |
|----------|---------|
| **System Health** | Heap usage, CPU load, thread count, GC time, uptime |
| **Processor Stats** | Per-processor errors, transactions, processing time |
| **Queue Monitoring** | Queue depth, stuck queue detection, backpressure |
| **Repository Storage** | FlowFile, Content, Provenance disk usage |
| **Alerting** | Queue stuck, GC spikes, high errors, memory critical |
| **Anomaly Detection** | Heap trends, transaction spikes, error patterns |

---

## Project Timeline

### Total Estimated Hours: 16-24 hours

| Phase | Duration | Tasks |
|-------|----------|-------|
| **Phase 1: Setup** | 2-3 hours | Environment setup, Elasticsearch configuration, index templates |
| **Phase 2: NiFi Flow** | 4-6 hours | Deploy monitoring flow, configure processors, test data collection |
| **Phase 3: Kibana** | 4-6 hours | Import dashboards, create visualizations, configure alerts |
| **Phase 4: Testing** | 3-4 hours | End-to-end testing, alert verification, performance tuning |
| **Phase 5: Documentation** | 2-3 hours | User guides, runbooks, training materials |
| **Phase 6: Deployment** | 1-2 hours | Production deployment, verification, handoff |

### Detailed Timeline

```
Week 1:
├── Day 1-2: Environment Setup & Elasticsearch Configuration
│   ├── Create Elasticsearch index templates
│   ├── Configure ILM policies
│   └── Set up authentication
│
├── Day 3-4: NiFi Flow Development
│   ├── Import monitoring flow template
│   ├── Configure API endpoints
│   ├── Set up Elasticsearch connection
│   └── Test data ingestion
│
└── Day 5: Kibana Dashboard Setup
    ├── Create index patterns
    ├── Import visualizations
    └── Configure dashboard layout

Week 2:
├── Day 1-2: Alert Configuration
│   ├── Create alert rules
│   ├── Configure notification channels
│   └── Test alert triggers
│
├── Day 3: Testing & Optimization
│   ├── Load testing
│   ├── Performance tuning
│   └── Documentation review
│
└── Day 4-5: Deployment & Handoff
    ├── Production deployment
    ├── User training
    └── Documentation finalization
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          NiFi Performance Monitoring                         │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Apache NiFi   │     │  Elasticsearch  │     │     Kibana      │
│    1.23.2       │────▶│     Cloud       │────▶│   Dashboards    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        │ NiFi API              │ Index/Query           │ Visualize
        │ Polling               │                       │
        ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Monitoring Flow │     │  Index Patterns │     │  Alert Rules    │
│                 │     │                 │     │                 │
│ • System Diag   │     │ • system-metrics│     │ • Queue Stuck   │
│ • Processor     │     │ • processor-stats│    │ • GC Spikes     │
│ • Connections   │     │ • connection-stats│   │ • High Errors   │
│ • Bulletins     │     │ • bulletins     │     │ • Heap Critical │
│ • Counters      │     │ • counters      │     │ • Disk Low      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### Data Flow

1. **Collection**: NiFi monitoring flow polls NiFi REST API every 30 seconds
2. **Processing**: Metrics are extracted, enriched with timestamps and metadata
3. **Indexing**: JSON documents are indexed to Elasticsearch
4. **Visualization**: Kibana dashboards query and display metrics
5. **Alerting**: Kibana rules monitor thresholds and trigger notifications

### Elasticsearch Indices

| Index Pattern | Description | Retention |
|---------------|-------------|-----------|
| `nifi-system-metrics*` | Heap, CPU, threads, GC, storage | 90 days |
| `nifi-processor-stats*` | Per-processor statistics | 90 days |
| `nifi-connection-stats*` | Queue and connection metrics | 90 days |
| `nifi-bulletins*` | Errors, warnings, bulletins | 90 days |
| `nifi-counters*` | Transaction counters | 90 days |

---

## Features

### 1. System Health Monitoring

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| Heap Usage | JVM heap memory utilization | > 90% |
| CPU Load | Processor load average | > 80% |
| Thread Count | Active and daemon threads | > 500 |
| GC Time | Garbage collection duration | Spike > 5s |
| Uptime | NiFi instance uptime | - |

### 2. Per Processor Error Trend

- Track errors by processor over time
- Identify error patterns and trends
- Drill down to specific error messages
- Compare error rates across processors

### 3. Transaction Spike Trend

- Monitor FlowFile throughput
- Detect unusual transaction spikes
- Calculate moving averages
- Identify processing bottlenecks

### 4. Repository Storage

| Repository | Metrics |
|------------|---------|
| FlowFile | Used, free, total space |
| Content | Used, free, total space |
| Provenance | Used, free, total space |

### 5. Queue Monitoring

- Queue depth per connection
- Backpressure status
- Stuck queue detection
- Queue flow rates

### 6. Alerts

| Alert | Condition | Severity |
|-------|-----------|----------|
| Queue Stuck | Queue items > 1000, no output for 5min | Critical |
| GC Spike | GC time increase > 5000ms | Warning |
| High Errors | > 10 errors in 5 minutes | Critical |
| Heap Critical | Heap utilization > 90% | Critical |
| Disk Low | Any repo > 85% full | Warning |
| CPU High | Load average > 0.8 | Warning |
| Thread High | Threads > 500 | Warning |

---

## Installation Guide

### Prerequisites

- Apache NiFi 1.23.2
- Elasticsearch Cloud (or self-hosted 7.x/8.x)
- Kibana 7.x/8.x
- Network connectivity between NiFi and Elasticsearch

### Step 1: Configure Elasticsearch

```bash
# Run the setup script
./scripts/setup-elasticsearch.sh \
  "https://your-elasticsearch-cloud.elastic-cloud.com:9243" \
  "elastic" \
  "your-password"
```

This creates:
- ILM policy for data retention
- Index templates for all metric types
- Field mappings for optimal querying

### Step 2: Import NiFi Flow

1. Open NiFi UI: `http://your-nifi-host:8080/nifi`
2. Right-click on canvas → "Upload Template"
3. Select `nifi-flows/NiFiPerformanceMonitoring.json`
4. Drag template onto canvas
5. Configure the `elasticsearch.url` variable

### Step 3: Configure NiFi Parameters

Create a Parameter Context named `NiFi Monitoring Parameters`:

| Parameter | Value |
|-----------|-------|
| `elasticsearch.url` | Your Elasticsearch URL |
| `elasticsearch.username` | Elasticsearch username |
| `elasticsearch.password` | Elasticsearch password (sensitive) |
| `nifi.api.url` | `http://localhost:8080/nifi-api` |
| `collection.interval` | `30 sec` |

### Step 4: Setup Kibana

```bash
# Run the Kibana setup script
./scripts/setup-kibana.sh \
  "https://your-kibana.elastic-cloud.com:9243" \
  "elastic" \
  "your-password"
```

This creates:
- Index patterns for all metric types
- Pre-built dashboard with visualizations
- Alert rule templates

### Step 5: Start Monitoring

1. In NiFi, start all process groups
2. Verify data appears in Kibana Discover
3. Open the NiFi Performance Monitoring Dashboard

---

## Configuration Guide

### Elasticsearch Connection (NiFi)

Configure the `PutElasticsearchHttp` processors:

| Property | Value |
|----------|-------|
| Elasticsearch URL | `https://your-es.elastic-cloud.com:9243` |
| Username | Your Elasticsearch username |
| Password | Your Elasticsearch password |
| SSL Context Service | Configure if using HTTPS |

### Collection Frequency

Adjust `schedulingPeriod` on InvokeHTTP processors:

| Metric Type | Recommended Interval |
|-------------|---------------------|
| System Diagnostics | 30 seconds |
| Processor Stats | 30 seconds |
| Connection Stats | 30 seconds |
| Bulletins | 15 seconds |
| Counters | 30 seconds |

### Data Retention (ILM)

Default policy:
- Hot: 0-7 days (on fast storage)
- Warm: 7-30 days (merged, shrunk)
- Cold: 30-90 days (no replicas)
- Delete: After 90 days

Modify in `elasticsearch/index-templates.json` as needed.

---

## Dashboard Guide

### Main Dashboard Panels

#### Row 1: System Health
- **Heap Usage Over Time**: Line chart of heap used vs max
- **CPU Load Average**: Line chart of processor load

#### Row 2: JVM Metrics
- **GC Time Trend**: Area chart showing GC time changes
- **Thread Count**: Line chart of total vs daemon threads
- **Uptime**: Metric showing current uptime

#### Row 3: Error & Transaction Analysis
- **Per Processor Error Trend**: Line chart grouped by processor
- **Transaction Spike Trend**: Line chart with moving average

#### Row 4: Storage
- **FlowFile Repo Disk Usage**: Donut chart
- **Content Repo Disk Usage**: Donut chart
- **Provenance Repo Disk Usage**: Donut chart

#### Row 5: Queue Monitoring
- **Queue Depth by Connection**: Histogram over time

#### Row 6: Alerts
- **Stuck Queue Alerts**: Table of stuck queues
- **Error Bulletins**: Table of recent errors

### Using Filters

- Time range: Use the time picker (default: last 24 hours)
- NiFi instance: Filter by `nifi_instance` field
- Processor: Filter by `processor_name` field
- Connection: Filter by `connection_name` field

---

## Alert Configuration

### Setting Up Slack Notifications

1. Create Slack webhook URL
2. In Kibana, go to Stack Management → Rules and Connectors
3. Create Slack connector with webhook URL
4. Assign to alert rules

### Setting Up Email Notifications

1. Configure SMTP in Kibana
2. Create Email connector
3. Assign to alert rules

### Setting Up PagerDuty

1. Get PagerDuty integration key
2. Create PagerDuty connector in Kibana
3. Assign to critical alerts

### Custom Alert Thresholds

Modify thresholds in `kibana/alert-rules.json`:

```json
{
  "name": "NiFi Heap Memory Critical Alert",
  "conditions": {
    "query": {
      "bool": {
        "must": [
          { "range": { "heapUtilizationPercent": { "gte": 90 } } }
        ]
      }
    }
  }
}
```

---

## Performance Optimization

### NiFi Flow Optimization

1. **Batch Size**: Increase `put-es-batch-size` for bulk indexing
2. **Connection Pooling**: Enable connection pooling in HTTP processors
3. **Back Pressure**: Configure appropriate back pressure settings
4. **Concurrent Tasks**: Adjust based on NiFi resources

### Elasticsearch Optimization

1. **Sharding**: Use time-based indices for better scaling
2. **Refresh Interval**: Increase for write-heavy workloads
3. **Bulk Size**: Optimize bulk request size
4. **ILM**: Use appropriate lifecycle policies

### Kibana Optimization

1. **Query Caching**: Enable for repeated queries
2. **Async Search**: Use for long-running queries
3. **Sampling**: Sample data for high-cardinality fields

---

## Troubleshooting

### No Data in Kibana

1. Check NiFi flow is running
2. Verify Elasticsearch connection in NiFi
3. Check for errors in NiFi bulletins
4. Verify index patterns in Kibana
5. Check time range in Kibana

### High Memory Usage in NiFi

1. Reduce collection frequency
2. Increase back pressure thresholds
3. Check for queue buildup
4. Review JVM heap settings

### Missing Metrics

1. Verify NiFi API is accessible
2. Check EvaluateJsonPath expressions
3. Review NiFi flow for errors
4. Check Elasticsearch mapping conflicts

### Alert Not Firing

1. Verify data is being indexed
2. Check alert threshold values
3. Review alert rule query
4. Check notification connector

---

## Support

For issues or questions:
1. Check NiFi bulletins for errors
2. Review Elasticsearch logs
3. Check Kibana stack management logs
4. Consult Apache NiFi documentation

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Initial | Initial release |

---

## License

This project is provided as-is for monitoring Apache NiFi deployments.
