# Apache NiFi Performance Monitoring with Elasticsearch & Kibana

<img width="507" height="761" alt="apache_nifi_elasticsearch" src="https://github.com/user-attachments/assets/344cb312-3a8a-48ff-9ffb-735c7350224f" />

## Overview

A comprehensive monitoring solution for Apache NiFi 1.23.2 that provides real-time performance visualization in Kibana using Elasticsearch Cloud. 

**This solution uses NiFi's built-in ReportingTask mechanism**, which is the recommended approach for metrics collection as it runs natively within NiFi with direct access to internal metrics, minimal overhead, and comprehensive data collection.

## Why ReportingTask?

| Aspect | ReportingTask (This Solution) | API-based Flows |
|--------|-------------------------------|-----------------|
| **Performance** | Native, minimal overhead | HTTP overhead, consumes flow resources |
| **Access** | Direct internal metrics access | Limited to REST API endpoints |
| **Reliability** | Built-in, maintained by NiFi | Custom flows require maintenance |
| **Configuration** | Simple UI configuration | Complex flow design |
| **Metrics Depth** | Full provenance, bulletins, status | Subset available via API |

## Features

### 📊 Dashboards

| Dashboard | Description |
|-----------|-------------|
| **System Health Dashboard** | JVM heap usage, CPU load, thread count, GC time, uptime |
| **Processor Performance Dashboard** | Per-processor error trends, transaction spike detection |
| **Storage Dashboard** | FlowFile, Content, and Provenance repository disk usage |
| **Queue Monitoring Dashboard** | Connection queue sizes and back pressure status |

### 🔔 Alerting

| Alert | Trigger Condition | Severity |
|-------|-------------------|----------|
| Queue Stuck | Queue size unchanged for >10 min with >1000 flowfiles | Critical |
| GC Spike | GC time exceeds 500ms in 5-minute window | Warning |
| High Transaction Errors | Error count exceeds threshold | Critical |
| Heap Usage Warning | Heap utilization exceeds 85% | Warning |
| Disk Usage Critical | Any repository exceeds 90% usage | Critical |

### 📈 Metrics Collected via ReportingTasks

**SiteToSiteMetricsReportingTask (System Health):**
- Heap usage (used, max, percentage)
- CPU load average
- Thread count (active, daemon, total)
- Garbage collection time and count
- System uptime
- Repository storage utilization

**SiteToSiteStatusReportingTask (Processor Performance):**
- FlowFiles in/out per processor
- Bytes read/written
- Processing time
- Queue depths and back pressure
- Transaction rates

**SiteToSiteBulletinReportingTask (Errors & Warnings):**
- Error bulletins with source component
- Warning messages
- Bulletin timestamps and details

**ElasticsearchProvenanceReporter (Optional - Data Lineage):**
- Provenance events
- Data flow tracking
- FlowFile lifecycle

## Project Structure

```
├── docs/
│   ├── IMPLEMENTATION_GUIDE.md         # Main implementation guide
│   └── REPORTINGTASK_CONFIGURATION.md  # Detailed ReportingTask setup
├── elasticsearch/
│   └── index-templates/                 # Elasticsearch index templates
│       ├── nifi-status-template.json    # For SiteToSiteStatusReportingTask
│       ├── nifi-metrics-template.json   # For SiteToSiteMetricsReportingTask
│       ├── nifi-bulletins-template.json # For SiteToSiteBulletinReportingTask
│       ├── nifi-provenance-template.json # For ElasticsearchProvenanceReporter
│       └── nifi-metrics-ilm-policy.json # Index lifecycle management
├── kibana/
│   ├── dashboards/
│   │   └── nifi-monitoring-dashboards.ndjson
│   └── alerts/
│       ├── queue-stuck-alert.json
│       ├── gc-spike-alert.json
│       ├── high-transaction-error-alert.json
│       ├── heap-usage-warning-alert.json
│       └── disk-usage-critical-alert.json
├── nifi-flows/                          # Legacy API-based flows (optional)
├── scripts/
│   └── setup.sh                         # Automated setup script
└── MonitoringHeartbeat.json             # Original heartbeat monitoring flow
```

## Quick Start

### Prerequisites

- Apache NiFi 1.23.2
- Elasticsearch Cloud (7.x or 8.x)
- Kibana

### Installation

1. **Deploy Elasticsearch Index Templates:**
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

2. **Configure NiFi ReportingTasks:**
   - Open NiFi UI → Controller Settings (hamburger menu)
   - Go to **Reporting Tasks** tab
   - Add and configure:
     - `SiteToSiteStatusReportingTask` (30 sec schedule)
     - `SiteToSiteMetricsReportingTask` (30 sec schedule)
     - `SiteToSiteBulletinReportingTask` (1 min schedule)
     - `ElasticsearchProvenanceReporter` (optional, 5 min schedule)
   - See [REPORTINGTASK_CONFIGURATION.md](docs/REPORTINGTASK_CONFIGURATION.md) for details

3. **Start ReportingTasks:**
   - Click the play button (▶) for each ReportingTask
   - Verify status shows "Running"

4. **Import Kibana Dashboards:**
   - Open Kibana → Stack Management → Saved Objects
   - Import `kibana/dashboards/nifi-monitoring-dashboards.ndjson`

## Timeline & Effort Estimate

| Phase | Description | Duration |
|-------|-------------|----------|
| Setup | Configure Elasticsearch templates | 2-3 hours |
| ReportingTask | Configure and enable ReportingTasks | 2-3 hours |
| Dashboards | Import and customize Kibana dashboards | 4-6 hours |
| Alerting | Configure alert rules and actions | 2-4 hours |
| Testing | Validate metrics collection and alerts | 1-2 hours |
| **Total** | | **12-18 hours** |

## Configuration

### ReportingTask Setup

Configure each ReportingTask in NiFi Controller Settings:

| ReportingTask | Schedule | Metrics |
|---------------|----------|---------|
| SiteToSiteStatusReportingTask | 30 sec | Processor status, queues, throughput |
| SiteToSiteMetricsReportingTask | 30 sec | JVM heap, CPU, threads, GC, uptime |
| SiteToSiteBulletinReportingTask | 1 min | Errors, warnings |
| ElasticsearchProvenanceReporter | 5 min | Data lineage (optional) |

### Elasticsearch Connection

Configure in each ReportingTask:
- Elasticsearch URL: `https://your-deployment.es.cloud.es.io:9243`
- Username/Password or API Key
- SSL Context Service (for HTTPS)

## Documentation

- **[Implementation Guide](docs/IMPLEMENTATION_GUIDE.md)** - Complete setup instructions
- **[ReportingTask Configuration](docs/REPORTINGTASK_CONFIGURATION.md)** - Detailed ReportingTask setup

## License

This project is provided as-is for monitoring Apache NiFi environments.

## Support

For issues or questions:
1. Check the troubleshooting section in the implementation guide
2. Review NiFi and Elasticsearch logs
3. Open an issue in this repository
