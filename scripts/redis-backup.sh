#!/bin/sh
# Redis backup script

set -e

BACKUP_DIR="../backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/redis_backup_${TIMESTAMP}.rdb"

mkdir -p "$BACKUP_DIR"

echo "💾 Creating Redis backup..."
redis-cli -h ${REDIS_HOST:-localhost} -p ${REDIS_PORT:-6379} SAVE
docker cp wander-redis:/data/dump.rdb "$BACKUP_FILE" 2>/dev/null || echo "⚠️  Redis backup requires running container"

echo "✅ Redis backup created: $BACKUP_FILE"

