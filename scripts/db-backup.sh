#!/bin/sh
# Database backup script

set -e

BACKUP_DIR="../backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

echo "💾 Creating database backup..."
PGPASSWORD=${POSTGRES_PASSWORD:-dev_password_123} pg_dump \
  -h ${POSTGRES_HOST:-localhost} \
  -p ${POSTGRES_PORT:-5432} \
  -U ${POSTGRES_USER:-wander} \
  -d ${POSTGRES_DB:-wander_dev} \
  > "$BACKUP_FILE"

echo "✅ Backup created: $BACKUP_FILE"

