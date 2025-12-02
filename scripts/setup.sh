#!/bin/bash
#
# NiFi Monitoring Solution Setup Script
# This script helps deploy the Elasticsearch templates and configure the monitoring solution
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "NiFi Performance Monitoring Setup Script"
echo "========================================"
echo ""

# Check for required tools
command -v curl >/dev/null 2>&1 || { echo -e "${RED}Error: curl is required but not installed.${NC}" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo -e "${YELLOW}Warning: jq is not installed. JSON output will not be pretty-printed.${NC}"; }

# Prompt for Elasticsearch connection details
read -p "Enter Elasticsearch URL (e.g., https://your-deployment.es.cloud.es.io:9243): " ES_URL
read -p "Enter Elasticsearch username (default: elastic): " ES_USER
ES_USER=${ES_USER:-elastic}
read -s -p "Enter Elasticsearch password: " ES_PASS
echo ""

# Test connection
echo -e "\n${YELLOW}Testing Elasticsearch connection...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "$ES_USER:$ES_PASS" "$ES_URL")
if [ "$HTTP_CODE" != "200" ]; then
    echo -e "${RED}Error: Could not connect to Elasticsearch (HTTP $HTTP_CODE)${NC}"
    exit 1
fi
echo -e "${GREEN}Connection successful!${NC}"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Deploy ILM Policy
echo -e "\n${YELLOW}Deploying ILM Policy...${NC}"
curl -s -X PUT "$ES_URL/_ilm/policy/nifi-metrics-ilm-policy" \
    -H "Content-Type: application/json" \
    -u "$ES_USER:$ES_PASS" \
    -d @"$PARENT_DIR/elasticsearch/index-templates/nifi-metrics-ilm-policy.json" > /dev/null
echo -e "${GREEN}ILM Policy created successfully${NC}"

# Deploy Index Templates
echo -e "\n${YELLOW}Deploying Index Templates...${NC}"

for template in "$PARENT_DIR/elasticsearch/index-templates/nifi-"*"-template.json"; do
    template_name=$(basename "$template" .json | sed 's/-template//')
    echo "  Creating template: $template_name"
    curl -s -X PUT "$ES_URL/_index_template/$template_name" \
        -H "Content-Type: application/json" \
        -u "$ES_USER:$ES_PASS" \
        -d @"$template" > /dev/null
done
echo -e "${GREEN}Index Templates created successfully${NC}"

# Prompt for Kibana import
echo -e "\n${YELLOW}Would you like to import Kibana dashboards? (y/n)${NC}"
read -p "> " IMPORT_KIBANA

if [ "$IMPORT_KIBANA" == "y" ] || [ "$IMPORT_KIBANA" == "Y" ]; then
    read -p "Enter Kibana URL (e.g., https://your-deployment.kb.cloud.es.io:9243): " KIBANA_URL
    
    echo -e "\n${YELLOW}Importing Kibana dashboards...${NC}"
    curl -s -X POST "$KIBANA_URL/api/saved_objects/_import?overwrite=true" \
        -H "kbn-xsrf: true" \
        -u "$ES_USER:$ES_PASS" \
        -F file=@"$PARENT_DIR/kibana/dashboards/nifi-monitoring-dashboards.ndjson" > /dev/null
    echo -e "${GREEN}Kibana dashboards imported successfully${NC}"
fi

# Summary
echo -e "\n${GREEN}========================================"
echo "Setup Complete!"
echo "========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Import NiFi flow templates from nifi-flows/"
echo "2. Configure the flows with your NiFi API URL and Elasticsearch credentials"
echo "3. Start the monitoring flows"
echo "4. View dashboards in Kibana"
echo ""
echo "For detailed instructions, see docs/IMPLEMENTATION_GUIDE.md"
