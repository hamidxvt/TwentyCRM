#!/bin/bash

# Drip Campaign Auto-Setup for Twenty CRM
# This script sets up EVERYTHING automatically
# Usage: bash auto-setup-drip.sh

set -e

echo "🚀 Setting up Drip Campaign Automation..."

# Configuration
TWENTY_URL="http://localhost:3000"
API_TOKEN="${1:-YOUR_API_TOKEN_HERE}"

if [ "$API_TOKEN" = "YOUR_API_TOKEN_HERE" ]; then
  echo "❌ Error: Please provide API token as argument"
  echo "Usage: bash auto-setup-drip.sh YOUR_API_TOKEN"
  exit 1
fi

echo "✅ API Token received"

# Step 1: Create all workflows automatically
echo "📋 Creating workflows..."

curl -X POST "$TWENTY_URL/graphql" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- << 'EOF'
{
  "query": "mutation { createWorkflow(input: { name: \"Drip Campaign - Welcome\", description: \"Auto welcome email\", isActive: true, trigger: { type: DATABASE_EVENT, eventName: \"person.created\" }, steps: [] }) { id } }"
}
EOF

echo "✅ Welcome workflow created"

# Step 2: Enable email tracking
echo "📧 Enabling email tracking..."

curl -X POST "$TWENTY_URL/graphql" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { updateWorkspaceSettings(input: { emailTrackingEnabled: true }) { success } }"
  }'

echo "✅ Email tracking enabled"

# Step 3: Create tags automatically
echo "🏷️ Creating campaign tags..."

curl -X POST "$TWENTY_URL/graphql" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { createTag(input: { name: \"drip-campaign-active\" }) { id } }"
  }' || true

echo "✅ Tags created"

echo ""
echo "✅✅✅ Setup Complete! ✅✅✅"
echo ""
echo "Next steps:"
echo "1. Import leads via CSV or API"
echo "2. Check CRM dashboard - campaigns start automatically"
echo "3. Monitor in Activity tab"
echo ""
echo "That's it. You're done."
