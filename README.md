# NiFi Performance Monitoring with Elasticsearch and Kibana

<img width="507" height="761" alt="apache_nifi_elasticsearch" src="https://github.com/user-attachments/assets/344cb312-3a8a-48ff-9ffb-735c7350224f" />

## Overview

A comprehensive Apache NiFi 1.23.2 performance monitoring solution integrated with Elasticsearch Cloud and Kibana. This project provides real-time visibility into NiFi's health, performance, and operational metrics.

## Features

### 📊 System Health Monitoring
- **Heap Usage**: Real-time JVM heap memory tracking with trend analysis
- **CPU Load**: Processor load average monitoring
- **Thread Count**: Total and daemon thread monitoring
- **GC Time**: Garbage collection time and frequency tracking
- **Uptime**: NiFi instance availability tracking

### 📈 Processor Performance
- **Per-Processor Error Trend**: Track errors by processor over time
- **Transaction Spike Detection**: Identify unusual FlowFile throughput patterns
- **Processing Time Analysis**: Monitor task duration and performance

### 🔗 Queue Monitoring
- **Queue Depth**: Real-time queue depth per connection
- **Stuck Queue Detection**: Automatic detection of queues with no output
- **Backpressure Monitoring**: Track queue utilization percentages

### 💾 Repository Storage
- **FlowFile Repository**: Disk usage monitoring
- **Content Repository**: Storage utilization tracking
- **Provenance Repository**: Historical data storage monitoring

### 🚨 Intelligent Alerting
| Alert Type | Description |
|------------|-------------|
| Queue Stuck | Detects queues with items but no output |
| GC Spikes | Alerts on significant GC time increases |
| High Transaction Errors | Triggers when error rate exceeds threshold |
| Heap Memory Critical | Warns when heap utilization > 90% |
| Disk Space Low | Alerts when any repository > 85% full |
| CPU Load High | Monitors sustained high CPU usage |

### 🔍 Anomaly Detection
- Heap memory usage anomalies
- Transaction volume spike detection
- Error pattern analysis

## Quick Start

### Prerequisites
- Apache NiFi 1.23.2
- Elasticsearch Cloud (or self-hosted 7.x/8.x)
- Kibana 7.x/8.x

### Installation

1. **Setup Elasticsearch**
   ```bash
   ./scripts/setup-elasticsearch.sh <ES_URL> <USERNAME> <PASSWORD>
   ```

2. **Import NiFi Flow**
   - Import `nifi-flows/NiFiPerformanceMonitoring.json` into NiFi
   - Configure Elasticsearch connection parameters

3. **Setup Kibana**
   ```bash
   ./scripts/setup-kibana.sh <KIBANA_URL> <USERNAME> <PASSWORD>
   ```

4. **Start Monitoring**
   - Start the NiFi monitoring flow
   - Open the Kibana dashboard

## Project Structure

```
├── nifi-flows/
│   └── NiFiPerformanceMonitoring.json    # Main NiFi monitoring flow
├── elasticsearch/
│   └── index-templates.json               # ES index templates & ILM
├── kibana/
│   ├── nifi-dashboard.ndjson             # Kibana dashboard export
│   └── alert-rules.json                  # Alert rule configurations
├── scripts/
│   ├── setup-elasticsearch.sh            # ES setup script
│   └── setup-kibana.sh                   # Kibana setup script
├── docs/
│   └── PROJECT_DOCUMENTATION.md          # Full project documentation
└── MonitoringHeartbeat.json              # Original heartbeat flow
```

## Documentation

For detailed documentation including:
- Complete project timeline (16-24 hours)
- Architecture overview
- Configuration guide
- Troubleshooting guide

See [docs/PROJECT_DOCUMENTATION.md](docs/PROJECT_DOCUMENTATION.md)

## Timeline Summary

| Phase | Duration |
|-------|----------|
| Setup | 2-3 hours |
| NiFi Flow | 4-6 hours |
| Kibana | 4-6 hours |
| Testing | 3-4 hours |
| Documentation | 2-3 hours |
| Deployment | 1-2 hours |
| **Total** | **16-24 hours** |

## Dashboard Preview

The Kibana dashboard includes:
- Heap usage trend charts
- CPU load visualization
- GC time analysis
- Thread count monitoring
- Per-processor error trends
- Transaction spike detection
- Repository disk usage gauges
- Queue depth monitoring
- Alert status tables

## Metrics Collected

| Index | Metrics |
|-------|---------|
| `nifi-system-metrics` | Heap, CPU, threads, GC, storage |
| `nifi-processor-stats` | Transactions, processing time, thread count |
| `nifi-connection-stats` | Queue depth, flow rates, stuck detection |
| `nifi-bulletins` | Errors, warnings, system messages |
| `nifi-counters` | Transaction counters |

## Data Retention

Default ILM policy:
- **Hot**: 0-7 days
- **Warm**: 7-30 days
- **Cold**: 30-90 days
- **Delete**: After 90 days

## Contributing

Contributions are welcome! Please read the documentation before submitting changes.

## License

This project is provided as-is for monitoring Apache NiFi deployments
