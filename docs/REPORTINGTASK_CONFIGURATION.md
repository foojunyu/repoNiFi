# NiFi ReportingTask Configuration Guide

This document provides detailed step-by-step instructions for configuring NiFi ReportingTasks to send metrics to Elasticsearch Cloud.

## Overview

ReportingTasks are the **recommended approach** for NiFi monitoring because they:
- Run natively inside NiFi with direct access to internal metrics
- Have minimal performance overhead compared to API-based polling
- Are maintained by the Apache NiFi community
- Provide comprehensive metrics not available via REST API

## Prerequisites

1. Apache NiFi 1.23.2 installed and running
2. Elasticsearch Cloud instance with:
   - HTTPS endpoint URL
   - User credentials with write permissions
   - Index templates deployed (see main guide)

## Step 1: Access Controller Settings

1. Open NiFi UI at `http://your-nifi-host:8080/nifi`
2. Click the hamburger menu (☰) in the top-right corner
3. Select **Controller Settings**

## Step 2: Create ElasticSearchClientService

Before configuring ReportingTasks, create a shared controller service for Elasticsearch connection.

### 2.1 Navigate to Controller Services Tab

1. In Controller Settings, click the **Reporting Task Controller Services** tab
2. Click the **+** button to add a new service

### 2.2 Configure ElasticSearchClientService

Search for and select `ElasticSearchClientService`, then configure:

| Property | Value | Notes |
|----------|-------|-------|
| **HTTP Hosts** | `https://your-deployment.es.cloud.es.io:9243` | Your ES Cloud endpoint |
| **Username** | `elastic` | ES username |
| **Password** | `<your-password>` | ES password |
| **Connection Timeout** | `5 secs` | Connection timeout |
| **Socket Timeout** | `30 secs` | Socket timeout |
| **Retry Timeout** | `30 secs` | Retry timeout |
| **SSL Context Service** | (optional) | Configure if using custom SSL |

### 2.3 Enable the Controller Service

1. Click the lightning bolt icon (⚡) next to the service
2. Confirm to enable the service
3. Status should change to **Enabled**

## Step 3: Configure SiteToSiteStatusReportingTask

This task collects processor status, queue depths, and throughput metrics.

### 3.1 Add ReportingTask

1. Navigate to **Reporting Tasks** tab
2. Click the **+** button
3. Search for and select `SiteToSiteStatusReportingTask`

### 3.2 Configure Properties

Click the pencil icon to configure:

**SCHEDULING Tab:**
| Property | Value |
|----------|-------|
| Run Schedule | `30 sec` |
| Scheduling Strategy | Timer driven |

**PROPERTIES Tab:**
| Property | Value | Description |
|----------|-------|-------------|
| Destination URL | `https://your-es:9243` | ES endpoint |
| SSL Context Service | (your SSL service) | If using HTTPS |
| Instance URL | `http://localhost:8080` | This NiFi instance |
| Input Port Name | `nifi-status` | Port name |
| Batch Size | `1000` | Records per batch |
| Compress | `true` | Compress transfers |
| Communications Timeout | `30 secs` | Timeout |
| Platform | `nifi` | Platform identifier |
| Component Type Filter | | Leave empty for all |
| Component Name Filter | | Leave empty for all |

### 3.3 Start the ReportingTask

1. Click the play button (▶) to start
2. Verify status shows **Running**

## Step 4: Configure SiteToSiteMetricsReportingTask

This task collects JVM metrics including heap, GC, threads, and CPU.

### 4.1 Add ReportingTask

1. Click **+** to add new ReportingTask
2. Select `SiteToSiteMetricsReportingTask`

### 4.2 Configure Properties

**SCHEDULING Tab:**
| Property | Value |
|----------|-------|
| Run Schedule | `30 sec` |

**PROPERTIES Tab:**
| Property | Value | Description |
|----------|-------|-------------|
| Destination URL | `https://your-es:9243` | ES endpoint |
| SSL Context Service | (your SSL service) | If using HTTPS |
| Input Port Name | `nifi-metrics` | Port name |
| Application ID | `nifi` | App identifier |
| Hostname | `${hostname()}` | Node hostname |

### 4.3 Metrics Collected

This task reports:
- `jvm.uptime` - JVM uptime in milliseconds
- `jvm.heap.used` - Used heap memory in bytes
- `jvm.heap.usage` - Heap usage percentage
- `jvm.heap.max` - Maximum heap size
- `jvm.gc.runs` - Total GC runs
- `jvm.gc.time` - Total GC time in milliseconds
- `jvm.thread.count` - Total thread count
- `jvm.thread.daemon.count` - Daemon thread count
- `processor.loadAverage` - System load average
- Repository storage metrics

## Step 5: Configure SiteToSiteBulletinReportingTask

This task collects error bulletins and warnings for alerting.

### 5.1 Add ReportingTask

1. Click **+** to add new ReportingTask
2. Select `SiteToSiteBulletinReportingTask`

### 5.2 Configure Properties

**SCHEDULING Tab:**
| Property | Value |
|----------|-------|
| Run Schedule | `1 min` |

**PROPERTIES Tab:**
| Property | Value | Description |
|----------|-------|-------------|
| Destination URL | `https://your-es:9243` | ES endpoint |
| SSL Context Service | (your SSL service) | If using HTTPS |
| Input Port Name | `nifi-bulletins` | Port name |
| Platform | `nifi` | Platform identifier |
| Batch Size | `1000` | Records per batch |

### 5.3 Bulletin Levels Collected

- **ERROR** - Critical errors requiring attention
- **WARNING** - Potential issues to monitor
- **INFO** - Informational messages

## Step 6: Configure ElasticsearchProvenanceReporter (Optional)

This task sends provenance events directly to Elasticsearch for data lineage tracking.

### 6.1 Add ReportingTask

1. Click **+** to add new ReportingTask
2. Select `ElasticsearchProvenanceReporter`

### 6.2 Configure Properties

**SCHEDULING Tab:**
| Property | Value |
|----------|-------|
| Run Schedule | `5 min` |

**PROPERTIES Tab:**
| Property | Value | Description |
|----------|-------|-------------|
| ElasticSearch Client Service | (select your ES service) | Connection service |
| Index | `nifi-provenance` | Index name |
| Index Type | `_doc` | Document type |
| Batch Size | `500` | Events per batch |

### 6.3 Event Types Collected

- `CREATE` - FlowFile created
- `RECEIVE` - Data received
- `SEND` - Data sent
- `CLONE` - FlowFile cloned
- `FORK` - FlowFile forked
- `JOIN` - FlowFiles joined
- `DROP` - FlowFile dropped
- `ROUTE` - FlowFile routed
- `ATTRIBUTES_MODIFIED` - Attributes changed
- `CONTENT_MODIFIED` - Content changed

## Step 7: Verify Data Flow

### 7.1 Check Elasticsearch Indices

```bash
# Check if indices are receiving data
curl -X GET "https://your-es:9243/_cat/indices/nifi-*?v" -u elastic:password
```

Expected output:
```
health status index                    uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   nifi-status-2024.12.01   xxx...                 1   1       1234            0      1.2mb          600kb
green  open   nifi-metrics-2024.12.01  xxx...                 1   1        456            0      256kb          128kb
green  open   nifi-bulletins-2024.12.01 xxx...                1   1         12            0       64kb           32kb
```

### 7.2 Query Sample Data

```bash
# Get sample status metrics
curl -X GET "https://your-es:9243/nifi-status-*/_search?size=1" -u elastic:password

# Get sample JVM metrics
curl -X GET "https://your-es:9243/nifi-metrics-*/_search?size=1" -u elastic:password
```

## Troubleshooting

### ReportingTask Won't Start

**Symptoms:** ReportingTask status shows "Stopped" or "Invalid"

**Solutions:**
1. Check ReportingTask configuration for missing required properties
2. Verify controller service is enabled
3. Check NiFi logs: `$NIFI_HOME/logs/nifi-app.log`

### No Data in Elasticsearch

**Symptoms:** Indices exist but document count is 0

**Solutions:**
1. Verify Elasticsearch connectivity from NiFi host
2. Check Elasticsearch user has write permissions
3. Verify SSL configuration if using HTTPS
4. Check ReportingTask bulletins for errors

### Connection Timeout Errors

**Symptoms:** Timeout errors in ReportingTask bulletins

**Solutions:**
1. Increase `Communications Timeout` property
2. Verify network connectivity to Elasticsearch
3. Check firewall rules allow outbound HTTPS

### SSL/TLS Errors

**Symptoms:** SSL handshake failures

**Solutions:**
1. Create and configure an SSL Context Service
2. Import Elasticsearch CA certificate to NiFi truststore
3. Verify SSL Context Service is enabled

## Performance Tuning

### Scheduling Recommendations

| ReportingTask | Recommended Schedule | Rationale |
|---------------|---------------------|-----------|
| SiteToSiteStatusReportingTask | 30 sec | Balance between freshness and load |
| SiteToSiteMetricsReportingTask | 30 sec | JVM metrics change frequently |
| SiteToSiteBulletinReportingTask | 1 min | Bulletins don't need real-time |
| ElasticsearchProvenanceReporter | 5 min | High volume, batch efficiently |

### Batch Size Tuning

- **Low volume flows:** Batch size 100-500
- **Medium volume flows:** Batch size 500-1000
- **High volume flows:** Batch size 1000-5000

### Network Optimization

- Enable compression (`Compress = true`)
- Use appropriate timeouts based on network latency
- Consider connection pooling for high-volume scenarios

## Summary

After completing this guide, you should have:

1. ✅ ElasticSearchClientService configured and enabled
2. ✅ SiteToSiteStatusReportingTask running (processor/queue metrics)
3. ✅ SiteToSiteMetricsReportingTask running (JVM/system metrics)
4. ✅ SiteToSiteBulletinReportingTask running (error bulletins)
5. ✅ (Optional) ElasticsearchProvenanceReporter running

All metrics will be automatically sent to Elasticsearch where Kibana dashboards can visualize them.
