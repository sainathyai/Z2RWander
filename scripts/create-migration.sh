#!/bin/sh
# Create a new database migration file

if [ -z "$1" ]; then
    echo "Usage: ./scripts/create-migration.sh <migration-name>"
    echo "Example: ./scripts/create-migration.sh add_user_roles"
    exit 1
fi

MIGRATION_NAME=$1
TIMESTAMP=$(date +%Y%m%d%H%M%S)
MIGRATION_FILE="backend/migrations/${TIMESTAMP}_${MIGRATION_NAME}.sql"

cat > "$MIGRATION_FILE" << EOF
-- Migration: $MIGRATION_NAME
-- Created: $(date)

-- Add your migration SQL here

EOF

echo "✅ Created migration: $MIGRATION_FILE"
echo "📝 Edit the file and add your SQL statements"

