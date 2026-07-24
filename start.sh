#!/bin/sh
set -e

# Force database migrations to always run on startup,
# regardless of any DISABLE_DB_MIGRATIONS env var set externally.
export DISABLE_DB_MIGRATIONS=false

echo "==> Starting Twenty CRM (migrations enabled)..."
exec node /app/packages/twenty-server/dist/src/main.js
