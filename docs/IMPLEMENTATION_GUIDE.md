# Apache NiFi Performance Monitoring with Elasticsearch and Kibana

## Overview

This comprehensive solution enables real-time visualization of Apache NiFi 1.23.2 performance metrics in Kibana, providing deep insights into processor behavior, system health, storage usage, and automated alerting for critical conditions.

**This solution uses NiFi's built-in ReportingTask mechanism**, which is the recommended approach for metrics collection as it runs natively within NiFi, has direct access to internal metrics, and requires no external API calls.

## Table of Contents

1. [Project Timeline](#project-timeline)
2. [Architecture Overview](#architecture-overview)
3. [Why ReportingTask?](#why-reportingtask)
4. [Requirements](#requirements)
5. [Installation Guide](#installation-guide)
6. [ReportingTask Configuration](#reportingtask-configuration)
7. [Monitoring Dashboards](#monitoring-dashboards)
8. [Alerting Configuration](#alerting-configuration)
9. [Performance Optimization](#performance-optimization)
10. [Troubleshooting](#troubleshooting)

---

## Project Timeline

### Total Estimated Time: 12-18 Hours

| Phase | Tasks | Duration | Status |
|-------|-------|----------|--------|
| **Phase 1: Setup** | Configure Elasticsearch indices, Controller Services | 2-3 hours | Ready |
| **Phase 2: ReportingTask** | Configure and enable ReportingTasks | 2-3 hours | Ready |
| **Phase 3: Dashboards** | Create Kibana visualizations and dashboards | 4-6 hours | Ready |
| **Phase 4: Alerting** | Configure alert rules in Kibana | 2-4 hours | Ready |
| **Phase 5: Testing** | Validate metrics collection and alerts | 1-2 hours | - |

### Detailed Breakdown

#### Phase 1: Setup (2-3 hours)
- [ ] Configure Elasticsearch Cloud connection settings
- [ ] Create index templates for metrics data
- [ ] Create ElasticSearchClientService controller service in NiFi
- [ ] Verify network connectivity between NiFi and Elasticsearch

#### Phase 2: ReportingTask Configuration (2-3 hours)
- [ ] Configure ElasticsearchProvenanceReporter
- [ ] Configure SiteToSiteBulletinReportingTask
- [ ] Configure SiteToSiteStatusReportingTask
- [ ] Configure SiteToSiteMetricsReportingTask
- [ ] Test data ingestion to Elasticsearch

#### Phase 3: Dashboards (4-6 hours)
- [ ] Import pre-built Kibana dashboards
- [ ] Customize visualizations for your environment
- [ ] Create index patterns in Kibana
- [ ] Configure time-based refresh settings

#### Phase 4: Alerting (2-4 hours)
- [ ] Configure queue stuck alerts
- [ ] Configure GC spike alerts
- [ ] Configure high transaction error alerts
- [ ] Set up alert actions (email, webhook, etc.)

#### Phase 5: Testing (1-2 hours)
- [ ] Validate all metrics are being collected
- [ ] Test alert triggers
- [ ] Performance test under load
- [ ] Document baseline metrics

---

## Why ReportingTask?

ReportingTask is the **recommended approach** for NiFi metrics collection because:

| Aspect | ReportingTask | API-based Flows |
|--------|---------------|-----------------|
| **Performance** | Native, minimal overhead | HTTP overhead, consumes flow resources |
| **Access** | Direct internal metrics access | Limited to REST API endpoints |
| **Reliability** | Built-in, maintained by NiFi | Custom flows require maintenance |
| **Configuration** | Simple UI configuration | Complex flow design |
| **Metrics Depth** | Full provenance, bulletins, status | Subset available via API |
| **Cluster Support** | Automatic cluster-aware | Manual cluster handling |

### Available ReportingTasks in NiFi 1.23.2

| ReportingTask | Metrics Collected |
|---------------|-------------------|
| **SiteToSiteStatusReportingTask** | Processor status, connection queues, throughput |
| **SiteToSiteMetricsReportingTask** | JVM metrics, system metrics (heap, CPU, threads, GC) |
| **SiteToSiteBulletinReportingTask** | Errors, warnings, bulletins |
| **ElasticsearchProvenanceReporter** | Provenance events, data lineage |
| **AmbariReportingTask** | Ambari-compatible metrics |
| **PrometheusReportingTask** | Prometheus-format metrics |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Apache NiFi 1.23.2                       │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                   Controller Services                      │   │
│  │  • ElasticSearchClientService (connection to ES Cloud)    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    ReportingTasks                          │   │
│  │                                                            │   │
│  │  ┌─────────────────────────────────────────────────────┐  │   │
│  │  │  SiteToSiteStatusReportingTask                      │  │   │
│  │  │  → Processor stats, queue depths, throughput        │  │   │
│  │  │  → Schedule: 30 seconds                             │  │   │
│  │  └─────────────────────────────────────────────────────┘  │   │
│  │                                                            │   │
│  │  ┌─────────────────────────────────────────────────────┐  │   │
│  │  │  SiteToSiteMetricsReportingTask                     │  │   │
│  │  │  → JVM heap, CPU, threads, GC, uptime               │  │   │
│  │  │  → Schedule: 30 seconds                             │  │   │
│  │  └─────────────────────────────────────────────────────┘  │   │
│  │                                                            │   │
│  │  ┌─────────────────────────────────────────────────────┐  │   │
│  │  │  SiteToSiteBulletinReportingTask                    │  │   │
│  │  │  → Errors, warnings, processor issues               │  │   │
│  │  │  → Schedule: 1 minute                               │  │   │
│  │  └─────────────────────────────────────────────────────┘  │   │
│  │                                                            │   │
│  │  ┌─────────────────────────────────────────────────────┐  │   │
│  │  │  ElasticsearchProvenanceReporter (Optional)         │  │   │
│  │  │  → Data lineage, provenance events                  │  │   │
│  │  │  → Schedule: 5 minutes                              │  │   │
│  │  └─────────────────────────────────────────────────────┘  │   │
│  │                                                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │ Direct push to Elasticsearch
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Elasticsearch Cloud                          │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  Indices:                                                    ││
│  │  • nifi-status-*         (processor status, queues, bytes)  ││
│  │  • nifi-metrics-*        (heap, CPU, threads, GC, uptime)   ││
│  │  • nifi-bulletins-*      (errors, warnings)                 ││
│  │  • nifi-provenance-*     (data lineage - optional)          ││
│  └─────────────────────────────────────────────────────────────┘│
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                          Kibana                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  Dashboards:                                                 ││
│  │  • NiFi Overview Dashboard                                   ││
│  │  • Processor Performance Dashboard                           ││
│  │  • System Health Dashboard                                   ││
│  │  • Storage & Repository Dashboard                            ││
│  │  • Alerts & Anomalies Dashboard                              ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  Alerting Rules:                                             ││
│  │  • Queue Stuck Alert                                         ││
│  │  • GC Spike Alert                                            ││
│  │  • High Transaction Error Alert                              ││
│  │  • Heap Usage Warning                                        ││
│  │  • Disk Usage Critical Alert                                 ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## Requirements

### System Requirements

| Component | Version | Purpose |
|-----------|---------|---------|
| Apache NiFi | 1.23.2 | Data flow platform |
| Elasticsearch | 7.x / 8.x | Metrics storage |
| Kibana | 7.x / 8.x | Visualization |

### NiFi ReportingTask Requirements

The monitoring solution uses NiFi's built-in ReportingTasks. Ensure:

1. NiFi has network access to Elasticsearch Cloud
2. SSL certificates are configured (for HTTPS connections)
3. Elasticsearch user has write permissions to indices

### Elasticsearch Cloud Configuration

```yaml
# Connection settings
elasticsearch.url: "https://your-deployment.es.cloud.es.io:9243"
elasticsearch.username: "elastic"
elasticsearch.password: "<your-password>"
# or use API key:
elasticsearch.api_key: "<your-api-key>"
```

---

## Installation Guide

### Step 1: Create Elasticsearch Index Templates

Upload the index templates from `elasticsearch/index-templates/`:

```bash
# Status metrics template (for SiteToSiteStatusReportingTask)
curl -X PUT "https://your-es-cloud:9243/_index_template/nifi-status" \
  -H "Content-Type: application/json" \
  -u elastic:password \
  -d @elasticsearch/index-templates/nifi-status-template.json

# System metrics template (for SiteToSiteMetricsReportingTask)
curl -X PUT "https://your-es-cloud:9243/_index_template/nifi-metrics" \
  -H "Content-Type: application/json" \
  -u elastic:password \
  -d @elasticsearch/index-templates/nifi-metrics-template.json

# Bulletins template (for SiteToSiteBulletinReportingTask)
curl -X PUT "https://your-es-cloud:9243/_index_template/nifi-bulletins" \
  -H "Content-Type: application/json" \
  -u elastic:password \
  -d @elasticsearch/index-templates/nifi-bulletins-template.json

# Provenance template (for ElasticsearchProvenanceReporter - optional)
curl -X PUT "https://your-es-cloud:9243/_index_template/nifi-provenance" \
  -H "Content-Type: application/json" \
  -u elastic:password \
  -d @elasticsearch/index-templates/nifi-provenance-template.json
```

### Step 2: Configure Controller Services

1. Open NiFi UI at `http://your-nifi-host:8080/nifi`
2. Go to Controller Settings (hamburger menu → Controller Settings)
3. Navigate to the **Reporting Task Controller Services** tab
4. Add a new **ElasticSearchClientService** with settings:

| Property | Value |
|----------|-------|
| HTTP Hosts | `https://your-deployment.es.cloud.es.io:9243` |
| Username | `elastic` |
| Password | `<your-password>` |
| SSL Context Service | (configure if using HTTPS) |

5. Enable the controller service

---

## ReportingTask Configuration

### Step 3: Configure ReportingTasks

Navigate to Controller Settings → Reporting Tasks tab and add the following:

#### 3.1 SiteToSiteStatusReportingTask

Collects processor status, queue depths, and throughput metrics.

| Property | Value | Description |
|----------|-------|-------------|
| Destination URL | `https://your-es:9243` | Elasticsearch endpoint |
| Index | `nifi-status` | Index name |
| Index Operation | `index` | Index operation |
| Run Schedule | `30 sec` | Collection interval |
| Platform | `nifi` | Platform identifier |
| Instance URL | `http://localhost:8080` | NiFi instance URL |
| Component Type Filter | (leave empty for all) | Filter components |
| Component Name Filter | (leave empty for all) | Filter by name |

**Metrics Collected:**
- `bytesReceived`, `bytesSent`, `bytesRead`, `bytesWritten`
- `flowFilesReceived`, `flowFilesSent`, `flowFilesQueued`
- `queuedBytes`, `queuedCount`
- `activeThreadCount`, `terminatedThreadCount`
- Processor run status and health

#### 3.2 SiteToSiteMetricsReportingTask

Collects JVM and system-level metrics.

| Property | Value | Description |
|----------|-------|-------------|
| Destination URL | `https://your-es:9243` | Elasticsearch endpoint |
| Index | `nifi-metrics` | Index name |
| Run Schedule | `30 sec` | Collection interval |
| Application ID | `nifi` | Application identifier |
| Hostname | `${hostname()}` | Node hostname |

**Metrics Collected:**
- `jvm.heap.used`, `jvm.heap.usage`, `jvm.heap.max`
- `jvm.gc.runs`, `jvm.gc.time`
- `jvm.thread.count`, `jvm.daemon.thread.count`
- `jvm.uptime`
- `jvm.file.descriptor.usage`
- Repository storage metrics

#### 3.3 SiteToSiteBulletinReportingTask

Collects error bulletins and warnings.

| Property | Value | Description |
|----------|-------|-------------|
| Destination URL | `https://your-es:9243` | Elasticsearch endpoint |
| Index | `nifi-bulletins` | Index name |
| Run Schedule | `1 min` | Collection interval |
| Platform | `nifi` | Platform identifier |

**Metrics Collected:**
- Bulletin message, level (ERROR, WARNING, INFO)
- Source component ID, name, type
- Timestamp, node information

#### 3.4 ElasticsearchProvenanceReporter (Optional)

Collects data provenance events for lineage tracking.

| Property | Value | Description |
|----------|-------|-------------|
| ElasticSearch Client Service | (select your ES service) | Connection service |
| Index | `nifi-provenance` | Index name |
| Run Schedule | `5 min` | Collection interval |

**Metrics Collected:**
- Event type (CREATE, RECEIVE, SEND, etc.)
- Component details
- FlowFile attributes and content claims
- Relationship information

### Step 4: Start ReportingTasks

1. Select each ReportingTask
2. Click the play button (▶) to start
3. Verify status shows "Running"

### Step 5: Import Kibana Dashboards

1. Open Kibana at your Elasticsearch Cloud URL
2. Go to Stack Management → Saved Objects
3. Import `kibana/dashboards/nifi-monitoring-dashboards.ndjson`
4. Create index patterns:
   - `nifi-status-*`
   - `nifi-metrics-*`
   - `nifi-bulletins-*`
   - `nifi-provenance-*` (if using provenance)

### Step 6: Configure Alerts

1. Go to Kibana → Stack Management → Rules and Connectors
2. Import alert rules from `kibana/alerts/`
3. Configure alert actions (email, Slack, webhook, etc.)

---

## Monitoring Dashboards

### 1. NiFi Overview Dashboard

Provides a high-level view of your NiFi environment:

- **Cluster Health Status** - Overall cluster state
- **Active Threads** - Current thread utilization
- **Bytes In/Out** - Data throughput
- **FlowFiles Queued** - Queue depth across all connections
- **Recent Errors** - Error trends in last 24 hours

### 2. Processor Performance Dashboard

Deep dive into processor-level metrics:

- **Per-Processor Error Trend** - Line chart showing errors per processor over time
- **Transaction Spike Trend** - Anomaly detection for unusual transaction volumes
- **Processing Time Distribution** - Histogram of processor execution times
- **Bytes Read/Written** - I/O metrics per processor
- **FlowFile Count** - Volume processed per processor

### 3. System Health Dashboard

JVM and system-level monitoring:

- **Heap Usage Gauge** - Current heap utilization with thresholds
- **CPU Load** - System CPU utilization
- **Thread Count** - Active, blocked, waiting threads
- **GC Time** - Garbage collection duration trends
- **Uptime** - System uptime indicator
- **Memory Pools** - Detailed JVM memory breakdown

### 4. Storage & Repository Dashboard

Repository disk usage monitoring:

- **FlowFile Repository Usage** - Disk space used/available
- **Content Repository Usage** - Per-container storage metrics
- **Provenance Repository Usage** - Event storage utilization
- **Usage Trends** - Historical storage consumption
- **Disk Space Alerts** - Visual indicators for critical thresholds

### 5. Alerts & Anomalies Dashboard

Consolidated view of all alerts:

- **Active Alerts** - Currently triggered alerts
- **Alert History** - Historical alert timeline
- **Queue Stuck Indicators** - Connections with stalled queues
- **GC Anomalies** - Unusual garbage collection patterns
- **Transaction Error Spikes** - Error rate anomalies

---

## Alerting Configuration

### Alert Definitions

#### 1. Queue Stuck Alert

**Condition:** Queue size remains unchanged for > 10 minutes while having > 1000 flowfiles

```json
{
  "name": "NiFi Queue Stuck Alert",
  "consumer": "alerts",
  "schedule": {
    "interval": "5m"
  },
  "params": {
    "index": "nifi-connection-metrics-*",
    "timeField": "@timestamp",
    "aggType": "max",
    "aggField": "queuedCount",
    "groupBy": "connection.id",
    "threshold": 1000,
    "thresholdComparator": ">",
    "timeWindowSize": 10,
    "timeWindowUnit": "m"
  }
}
```

#### 2. GC Spike Alert

**Condition:** GC time exceeds 500ms in any 5-minute window

```json
{
  "name": "NiFi GC Spike Alert",
  "consumer": "alerts",
  "schedule": {
    "interval": "1m"
  },
  "params": {
    "index": "nifi-system-metrics-*",
    "timeField": "@timestamp",
    "aggType": "max",
    "aggField": "jvm.gc.collectionTime",
    "threshold": 500,
    "thresholdComparator": ">"
  }
}
```

#### 3. High Transaction Error Alert

**Condition:** Error rate exceeds 5% of total transactions

```json
{
  "name": "NiFi High Transaction Error Alert",
  "consumer": "alerts",
  "schedule": {
    "interval": "5m"
  },
  "params": {
    "index": "nifi-processor-metrics-*",
    "timeField": "@timestamp",
    "aggType": "avg",
    "aggField": "errorRate",
    "threshold": 5,
    "thresholdComparator": ">"
  }
}
```

#### 4. Heap Usage Warning

**Condition:** Heap utilization exceeds 85%

```json
{
  "name": "NiFi Heap Usage Warning",
  "consumer": "alerts",
  "schedule": {
    "interval": "1m"
  },
  "params": {
    "index": "nifi-system-metrics-*",
    "timeField": "@timestamp",
    "aggType": "max",
    "aggField": "jvm.heap.usedPercent",
    "threshold": 85,
    "thresholdComparator": ">"
  }
}
```

#### 5. Disk Usage Critical Alert

**Condition:** Any repository disk usage exceeds 90%

```json
{
  "name": "NiFi Disk Usage Critical",
  "consumer": "alerts",
  "schedule": {
    "interval": "5m"
  },
  "params": {
    "index": "nifi-storage-metrics-*",
    "timeField": "@timestamp",
    "aggType": "max",
    "aggField": "usedSpacePercent",
    "threshold": 90,
    "thresholdComparator": ">"
  }
}
```

---

## Performance Optimization

### NiFi Flow Optimization Tips

1. **Batch Processing**
   - Configure appropriate batch sizes for processors
   - Use `Run Duration` setting for high-volume processors

2. **Back Pressure Configuration**
   - Set appropriate back pressure thresholds
   - Monitor queue sizes and adjust as needed

3. **Thread Pool Sizing**
   - Monitor active thread utilization
   - Adjust `Max Timer Driven Thread Count` based on CPU cores

4. **Connection Optimization**
   - Use Load Balance for parallel processing
   - Enable compression for remote connections

### Elasticsearch Optimization

1. **Index Lifecycle Management (ILM)**
   ```json
   {
     "policy": {
       "phases": {
         "hot": {
           "actions": {
             "rollover": {
               "max_size": "50GB",
               "max_age": "7d"
             }
           }
         },
         "warm": {
           "min_age": "7d",
           "actions": {
             "shrink": { "number_of_shards": 1 },
             "forcemerge": { "max_num_segments": 1 }
           }
         },
         "delete": {
           "min_age": "30d",
           "actions": { "delete": {} }
         }
       }
     }
   }
   ```

2. **Shard Sizing**
   - Target 10-50GB per shard
   - Adjust number of shards based on data volume

3. **Refresh Interval**
   - Set to 30s for metrics indices (balances freshness vs. performance)

### Kibana Dashboard Optimization

1. **Time-Based Filtering**
   - Use relative time ranges
   - Enable auto-refresh for live monitoring

2. **Visualization Best Practices**
   - Limit cardinality in aggregations
   - Use date histogram for time-series data
   - Cache dashboard queries

---

## Troubleshooting

### Common Issues

#### 1. Metrics Not Appearing in Kibana

**Symptoms:** Dashboards show "No data" or missing visualizations

**Solutions:**
1. Verify NiFi monitoring flows are running
2. Check Elasticsearch connectivity from NiFi
3. Verify index pattern matches actual index names
4. Check time range in Kibana (ensure it includes recent data)

```bash
# Check if data exists in Elasticsearch
curl -X GET "https://your-es:9243/nifi-system-metrics-*/_count" -u elastic:password
```

#### 2. NiFi API Connection Errors

**Symptoms:** InvokeHTTP processors showing errors

**Solutions:**
1. Verify NiFi API URL is correct
2. Check authentication credentials
3. Ensure SSL certificates are configured (for HTTPS)
4. Verify network connectivity

#### 3. High Latency in Dashboards

**Symptoms:** Kibana dashboards slow to load

**Solutions:**
1. Reduce time range for queries
2. Enable query caching
3. Check Elasticsearch cluster health
4. Review shard allocation

#### 4. Alerts Not Triggering

**Symptoms:** Alert conditions met but no notifications

**Solutions:**
1. Verify alert rules are enabled
2. Check alert action configuration
3. Review Kibana alerting logs
4. Verify connector configuration (email, Slack, etc.)

---

## Appendix

### API Endpoints Used

| Endpoint | Metrics Collected |
|----------|-------------------|
| `/nifi-api/system-diagnostics` | Heap, GC, CPU, threads, uptime, repositories |
| `/nifi-api/flow/process-groups/root` | Processor stats, transactions, errors |
| `/nifi-api/counters` | Custom counters |
| `/nifi-api/controller/cluster` | Cluster node status |
| `/nifi-api/connections/{id}` | Queue sizes, back pressure |

### Metrics Reference

#### System Metrics
| Metric | Description | Unit |
|--------|-------------|------|
| `jvm.heap.used` | Used heap memory | bytes |
| `jvm.heap.max` | Maximum heap memory | bytes |
| `jvm.heap.usedPercent` | Heap utilization | percentage |
| `system.cpu.load` | System CPU utilization | percentage |
| `threads.active` | Active thread count | count |
| `gc.collectionCount` | GC collection count | count |
| `gc.collectionTime` | GC collection duration | milliseconds |
| `uptime` | System uptime | milliseconds |

#### Processor Metrics
| Metric | Description | Unit |
|--------|-------------|------|
| `processor.name` | Processor name | string |
| `processor.type` | Processor type | string |
| `bytesRead` | Bytes read | bytes |
| `bytesWritten` | Bytes written | bytes |
| `flowFilesIn` | FlowFiles received | count |
| `flowFilesOut` | FlowFiles transferred | count |
| `processingNanos` | Processing duration | nanoseconds |
| `errors` | Error count | count |

#### Storage Metrics
| Metric | Description | Unit |
|--------|-------------|------|
| `repository.name` | Repository name | string |
| `totalSpace` | Total disk space | bytes |
| `usedSpace` | Used disk space | bytes |
| `freeSpace` | Available disk space | bytes |
| `usedSpacePercent` | Usage percentage | percentage |

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review NiFi and Elasticsearch logs
3. Open an issue in this repository

---

*Last Updated: December 2024*
