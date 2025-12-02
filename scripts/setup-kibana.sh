#!/bin/bash
#
# NiFi Performance Monitoring - Kibana Setup Script
# This script imports the dashboard and visualizations into Kibana
#
# Usage: ./setup-kibana.sh <KIBANA_URL> <USERNAME> <PASSWORD>
#
# Requirements:
# - curl
# - The kibana/nifi-dashboard.ndjson file
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
KIBANA_URL="${1:-http://localhost:5601}"
KIBANA_USER="${2:-elastic}"
KIBANA_PASS="${3:-}"

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
if [ -n "$KIBANA_PASS" ]; then
    AUTH="-u ${KIBANA_USER}:${KIBANA_PASS}"
else
    AUTH=""
fi

log_info "Setting up Kibana for NiFi Performance Monitoring"
log_info "Kibana URL: ${KIBANA_URL}"

# Test connection
log_info "Testing Kibana connection..."
if ! curl -s ${AUTH} "${KIBANA_URL}/api/status" > /dev/null; then
    log_error "Cannot connect to Kibana at ${KIBANA_URL}"
    exit 1
fi
log_info "Kibana connection successful"

# Create Index Patterns
log_info "Creating index patterns..."

# nifi-system-metrics
curl -s -X POST ${AUTH} "${KIBANA_URL}/api/saved_objects/index-pattern/nifi-system-metrics*" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "nifi-system-metrics*",
      "timeFieldName": "@timestamp"
    }
  }' > /dev/null
log_info "  Created: nifi-system-metrics*"

# nifi-processor-stats
curl -s -X POST ${AUTH} "${KIBANA_URL}/api/saved_objects/index-pattern/nifi-processor-stats*" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "nifi-processor-stats*",
      "timeFieldName": "@timestamp"
    }
  }' > /dev/null
log_info "  Created: nifi-processor-stats*"

# nifi-connection-stats
curl -s -X POST ${AUTH} "${KIBANA_URL}/api/saved_objects/index-pattern/nifi-connection-stats*" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "nifi-connection-stats*",
      "timeFieldName": "@timestamp"
    }
  }' > /dev/null
log_info "  Created: nifi-connection-stats*"

# nifi-bulletins
curl -s -X POST ${AUTH} "${KIBANA_URL}/api/saved_objects/index-pattern/nifi-bulletins*" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "nifi-bulletins*",
      "timeFieldName": "@timestamp"
    }
  }' > /dev/null
log_info "  Created: nifi-bulletins*"

# nifi-counters
curl -s -X POST ${AUTH} "${KIBANA_URL}/api/saved_objects/index-pattern/nifi-counters*" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "nifi-counters*",
      "timeFieldName": "@timestamp"
    }
  }' > /dev/null
log_info "  Created: nifi-counters*"

# Import Dashboard
DASHBOARD_FILE="${PROJECT_DIR}/kibana/nifi-dashboard.ndjson"
if [ -f "$DASHBOARD_FILE" ]; then
    log_info "Importing dashboard..."
    curl -s -X POST ${AUTH} "${KIBANA_URL}/api/saved_objects/_import?overwrite=true" \
      -H "kbn-xsrf: true" \
      --form file=@"${DASHBOARD_FILE}" > /dev/null
    log_info "Dashboard imported successfully"
else
    log_warn "Dashboard file not found: ${DASHBOARD_FILE}"
fi

log_info ""
log_info "Kibana setup complete!"
log_info ""
log_info "Created resources:"
log_info "  - Index Pattern: nifi-system-metrics*"
log_info "  - Index Pattern: nifi-processor-stats*"
log_info "  - Index Pattern: nifi-connection-stats*"
log_info "  - Index Pattern: nifi-bulletins*"
log_info "  - Index Pattern: nifi-counters*"
log_info "  - Dashboard: NiFi Performance Monitoring Dashboard"
log_info ""
log_info "Access the dashboard at:"
log_info "  ${KIBANA_URL}/app/dashboards"
