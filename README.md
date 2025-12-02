# Apache NiFi Performance Monitoring with Elasticsearch & Kibana

<img width="507" height="761" alt="apache_nifi_elasticsearch" src="https://github.com/user-attachments/assets/344cb312-3a8a-48ff-9ffb-735c7350224f" />

## Overview

A comprehensive monitoring solution for Apache NiFi 1.23.2 that provides real-time performance visualization in Kibana using Elasticsearch Cloud. This solution enables you to monitor processor performance, system health, detect anomalies, and receive alerts for critical conditions.

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

### 📈 Metrics Collected

**System Health:**
- Heap usage (used, max, percentage)
- CPU load average
- Thread count (active, daemon, total)
- Garbage collection time and count
- System uptime

**Processor Performance:**
- FlowFiles in/out per processor
- Bytes read/written
- Processing time
- Error count and trends
- Transaction rates

**Repository Storage:**
- FlowFile repository disk usage
- Content repository disk usage
- Provenance repository disk usage
- Usage trends over time

## Project Structure

```
├── docs/
│   └── IMPLEMENTATION_GUIDE.md    # Detailed implementation guide
├── elasticsearch/
│   └── index-templates/           # Elasticsearch index templates
│       ├── nifi-system-metrics-template.json
│       ├── nifi-processor-metrics-template.json
│       ├── nifi-storage-metrics-template.json
│       ├── nifi-connection-metrics-template.json
│       └── nifi-metrics-ilm-policy.json
├── nifi-flows/
│   ├── SystemMetricsCollector.json      # System health metrics
│   ├── ProcessorMetricsCollector.json   # Per-processor metrics
│   ├── StorageMetricsCollector.json     # Repository storage metrics
│   └── ConnectionMetricsCollector.json  # Queue/connection metrics
├── kibana/
│   ├── dashboards/
│   │   └── nifi-monitoring-dashboards.ndjson
│   └── alerts/
│       ├── queue-stuck-alert.json
│       ├── gc-spike-alert.json
│       ├── high-transaction-error-alert.json
│       ├── heap-usage-warning-alert.json
│       └── disk-usage-critical-alert.json
├── scripts/
│   └── setup.sh                   # Automated setup script
└── MonitoringHeartbeat.json       # Original heartbeat monitoring flow
```

## Quick Start

### Prerequisites

- Apache NiFi 1.23.2
- Elasticsearch Cloud (7.x or 8.x)
- Kibana

### Installation

1. **Run the setup script:**
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

2. **Import NiFi flows:**
   - Open NiFi UI
   - Right-click canvas → Upload Template
   - Upload flows from `nifi-flows/`
   - Configure Elasticsearch connection in each flow

3. **Configure and start flows:**
   - Set `nifi.api.url` variable to your NiFi API endpoint
   - Configure Elasticsearch credentials in PutElasticsearch processors
   - Start the monitoring flows

4. **View dashboards:**
   - Open Kibana
   - Navigate to Dashboard
   - Select the imported NiFi monitoring dashboards

## Timeline & Effort Estimate

| Phase | Description | Duration |
|-------|-------------|----------|
| Setup | Configure Elasticsearch and NiFi API access | 2-3 hours |
| Data Collection | Deploy and configure NiFi monitoring flows | 4-6 hours |
| Dashboards | Import and customize Kibana dashboards | 4-6 hours |
| Alerting | Configure alert rules and actions | 2-4 hours |
| Testing | Validate metrics collection and alerts | 2-3 hours |
| Documentation | Create runbooks and training materials | 2 hours |
| **Total** | | **16-24 hours** |

## Configuration

### NiFi API Access

Set the `nifi.api.url` variable in each flow:
```
http://your-nifi-host:8080
```

For secured NiFi, configure SSL Context Service and authentication.

### Elasticsearch Connection

Configure the PutElasticsearchJson processors with:
- Elasticsearch URL
- Username/Password or API Key
- SSL Context Service (for HTTPS)

## Performance Optimization Tips

1. **NiFi Flow Optimization:**
   - Use appropriate batch sizes
   - Configure back pressure thresholds
   - Optimize thread pool sizing

2. **Elasticsearch Optimization:**
   - Use ILM for index lifecycle management
   - Configure appropriate shard sizes
   - Set refresh interval to 30s for metrics

3. **Dashboard Optimization:**
   - Use relative time ranges
   - Enable query caching
   - Limit aggregation cardinality

## Documentation

For detailed implementation instructions, see [docs/IMPLEMENTATION_GUIDE.md](docs/IMPLEMENTATION_GUIDE.md).

## License

This project is provided as-is for monitoring Apache NiFi environments.

## Support

For issues or questions:
1. Check the troubleshooting section in the implementation guide
2. Review NiFi and Elasticsearch logs
3. Open an issue in this repository
