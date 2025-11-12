#!/bin/sh
# Health check script for all services

set -e

echo "🔍 Checking service health..."

# Check PostgreSQL
if PGPASSWORD=${POSTGRES_PASSWORD:-dev_password_123} psql -h ${POSTGRES_HOST:-postgres} -p ${POSTGRES_PORT:-5432} -U ${POSTGRES_USER:-wander} -d ${POSTGRES_DB:-wander_dev} -c '\q' 2>/dev/null; then
  echo "✅ PostgreSQL: Healthy"
else
  echo "❌ PostgreSQL: Unhealthy"
  exit 1
fi

# Check Redis
if redis-cli -h ${REDIS_HOST:-redis} -p ${REDIS_PORT:-6379} ping > /dev/null 2>&1; then
  echo "✅ Redis: Healthy"
else
  echo "❌ Redis: Unhealthy"
  exit 1
fi

# Check API
if curl -f http://${API_HOST:-backend}:${API_PORT:-8080}/health > /dev/null 2>&1; then
  echo "✅ API: Healthy"
else
  echo "❌ API: Unhealthy"
  exit 1
fi

echo "✅ All services are healthy!"

