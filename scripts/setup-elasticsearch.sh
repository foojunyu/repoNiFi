#!/bin/bash
#
# NiFi Performance Monitoring - Elasticsearch Setup Script
# This script creates the necessary index templates and ILM policies in Elasticsearch
#
# Usage: ./setup-elasticsearch.sh <ELASTICSEARCH_URL> <USERNAME> <PASSWORD>
#
# Requirements:
# - curl
# - jq (optional, for better output formatting)
#

set -e

# Configuration
ES_URL="${1:-http://localhost:9200}"
ES_USER="${2:-elastic}"
ES_PASS="${3:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Build auth header
if [ -n "$ES_PASS" ]; then
    AUTH="-u ${ES_USER}:${ES_PASS}"
else
    AUTH=""
fi

log_info "Setting up Elasticsearch for NiFi Performance Monitoring"
log_info "Elasticsearch URL: ${ES_URL}"

# Test connection
log_info "Testing Elasticsearch connection..."
if ! curl -s ${AUTH} "${ES_URL}/_cluster/health" > /dev/null; then
    log_error "Cannot connect to Elasticsearch at ${ES_URL}"
    exit 1
fi
log_info "Elasticsearch connection successful"

# Create ILM Policy
log_info "Creating ILM policy: nifi-metrics-policy"
curl -s -X PUT ${AUTH} "${ES_URL}/_ilm/policy/nifi-metrics-policy" \
  -H "Content-Type: application/json" \
  -d '{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_age": "1d",
            "max_size": "50gb"
          }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "shrink": {
            "number_of_shards": 1
          },
          "forcemerge": {
            "max_num_segments": 1
          }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "allocate": {
            "number_of_replicas": 0
          }
        }
      },
      "delete": {
        "min_age": "90d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}'
echo ""

# Create Index Template: nifi-system-metrics
log_info "Creating index template: nifi-system-metrics"
curl -s -X PUT ${AUTH} "${ES_URL}/_index_template/nifi-system-metrics-template" \
  -H "Content-Type: application/json" \
  -d '{
  "index_patterns": ["nifi-system-metrics*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1,
      "index.lifecycle.name": "nifi-metrics-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "metric_type": { "type": "keyword" },
        "nifi_instance": { "type": "keyword" },
        "heapUsed": { "type": "keyword" },
        "heapMax": { "type": "keyword" },
        "heapUtilization": { "type": "keyword" },
        "heapUsedBytes": { "type": "long" },
        "heapMaxBytes": { "type": "long" },
        "heapUtilizationPercent": { "type": "float" },
        "availableProcessors": { "type": "integer" },
        "processorLoadAverage": { "type": "float" },
        "totalThreads": { "type": "integer" },
        "daemonThreads": { "type": "integer" },
        "uptime": { "type": "keyword" },
        "uptimeMillis": { "type": "long" },
        "gcCount": { "type": "long" },
        "gcTime": { "type": "keyword" },
        "gcTimeMillis": { "type": "long" },
        "flowFileRepoUsed": { "type": "keyword" },
        "flowFileRepoFree": { "type": "keyword" },
        "flowFileRepoTotal": { "type": "keyword" },
        "flowFileRepoUsedBytes": { "type": "long" },
        "flowFileRepoFreeBytes": { "type": "long" },
        "flowFileRepoTotalBytes": { "type": "long" },
        "flowFileRepoUtilization": { "type": "float" },
        "contentRepoUsed": { "type": "keyword" },
        "contentRepoFree": { "type": "keyword" },
        "contentRepoTotal": { "type": "keyword" },
        "contentRepoUsedBytes": { "type": "long" },
        "contentRepoFreeBytes": { "type": "long" },
        "contentRepoTotalBytes": { "type": "long" },
        "contentRepoUtilization": { "type": "float" },
        "provenanceRepoUsed": { "type": "keyword" },
        "provenanceRepoFree": { "type": "keyword" },
        "provenanceRepoTotal": { "type": "keyword" },
        "provenanceRepoUsedBytes": { "type": "long" },
        "provenanceRepoFreeBytes": { "type": "long" },
        "provenanceRepoTotalBytes": { "type": "long" },
        "provenanceRepoUtilization": { "type": "float" }
      }
    }
  }
}'
echo ""

# Create Index Template: nifi-processor-stats
log_info "Creating index template: nifi-processor-stats"
curl -s -X PUT ${AUTH} "${ES_URL}/_index_template/nifi-processor-stats-template" \
  -H "Content-Type: application/json" \
  -d '{
  "index_patterns": ["nifi-processor-stats*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1,
      "index.lifecycle.name": "nifi-metrics-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "metric_type": { "type": "keyword" },
        "nifi_instance": { "type": "keyword" },
        "processor_id": { "type": "keyword" },
        "processor_name": { "type": "keyword" },
        "processor_type": { "type": "keyword" },
        "processor_state": { "type": "keyword" },
        "activeThreadCount": { "type": "integer" },
        "bytesIn": { "type": "long" },
        "bytesOut": { "type": "long" },
        "bytesRead": { "type": "long" },
        "bytesWritten": { "type": "long" },
        "flowFilesIn": { "type": "long" },
        "flowFilesOut": { "type": "long" },
        "input": { "type": "keyword" },
        "output": { "type": "keyword" },
        "taskCount": { "type": "long" },
        "tasksDuration": { "type": "keyword" },
        "tasksDurationNanos": { "type": "long" },
        "terminatedThreadCount": { "type": "integer" },
        "processingNanos": { "type": "long" }
      }
    }
  }
}'
echo ""

# Create Index Template: nifi-connection-stats
log_info "Creating index template: nifi-connection-stats"
curl -s -X PUT ${AUTH} "${ES_URL}/_index_template/nifi-connection-stats-template" \
  -H "Content-Type: application/json" \
  -d '{
  "index_patterns": ["nifi-connection-stats*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1,
      "index.lifecycle.name": "nifi-metrics-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "metric_type": { "type": "keyword" },
        "nifi_instance": { "type": "keyword" },
        "connection_id": { "type": "keyword" },
        "connection_name": { "type": "keyword" },
        "source_name": { "type": "keyword" },
        "destination_name": { "type": "keyword" },
        "queuedCount": { "type": "long" },
        "queuedSize": { "type": "keyword" },
        "queuedSizeBytes": { "type": "long" },
        "queued": { "type": "keyword" },
        "percentUseCount": { "type": "float" },
        "percentUseBytes": { "type": "float" },
        "flowFilesIn": { "type": "long" },
        "flowFilesOut": { "type": "long" },
        "bytesIn": { "type": "long" },
        "bytesOut": { "type": "long" },
        "queue_stuck_alert": { "type": "boolean" }
      }
    }
  }
}'
echo ""

# Create Index Template: nifi-bulletins
log_info "Creating index template: nifi-bulletins"
curl -s -X PUT ${AUTH} "${ES_URL}/_index_template/nifi-bulletins-template" \
  -H "Content-Type: application/json" \
  -d '{
  "index_patterns": ["nifi-bulletins*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1,
      "index.lifecycle.name": "nifi-metrics-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "metric_type": { "type": "keyword" },
        "nifi_instance": { "type": "keyword" },
        "bulletin_id": { "type": "keyword" },
        "bulletin_category": { "type": "keyword" },
        "bulletin_level": { "type": "keyword" },
        "bulletin_message": { "type": "text", "fields": { "keyword": { "type": "keyword", "ignore_above": 256 } } },
        "bulletin_timestamp": { "type": "date", "format": "yyyy-MM-dd HH:mm:ss,SSS||yyyy-MM-dd'"'"'T'"'"'HH:mm:ss.SSS'"'"'Z'"'"'||epoch_millis" },
        "source_id": { "type": "keyword" },
        "source_name": { "type": "keyword" },
        "source_type": { "type": "keyword" },
        "group_id": { "type": "keyword" },
        "group_name": { "type": "keyword" },
        "is_error": { "type": "boolean" }
      }
    }
  }
}'
echo ""

# Create Index Template: nifi-counters
log_info "Creating index template: nifi-counters"
curl -s -X PUT ${AUTH} "${ES_URL}/_index_template/nifi-counters-template" \
  -H "Content-Type: application/json" \
  -d '{
  "index_patterns": ["nifi-counters*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1,
      "index.lifecycle.name": "nifi-metrics-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "metric_type": { "type": "keyword" },
        "nifi_instance": { "type": "keyword" },
        "counter_id": { "type": "keyword" },
        "counter_context": { "type": "keyword" },
        "counter_name": { "type": "keyword" },
        "counter_value": { "type": "long" }
      }
    }
  }
}'
echo ""

log_info "Elasticsearch setup complete!"
log_info ""
log_info "Created resources:"
log_info "  - ILM Policy: nifi-metrics-policy"
log_info "  - Index Template: nifi-system-metrics-template"
log_info "  - Index Template: nifi-processor-stats-template"
log_info "  - Index Template: nifi-connection-stats-template"
log_info "  - Index Template: nifi-bulletins-template"
log_info "  - Index Template: nifi-counters-template"
log_info ""
log_info "Next steps:"
log_info "  1. Import the NiFi flow template into NiFi"
log_info "  2. Configure the Elasticsearch connection in NiFi"
log_info "  3. Import the Kibana dashboard"
log_info "  4. Start the NiFi flow to begin collecting metrics"
