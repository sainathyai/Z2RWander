#!/bin/sh
# Seed the database with sample data

set -e

POSTGRES_USER=${POSTGRES_USER:-wander}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-dev_password_123}
POSTGRES_DB=${POSTGRES_DB:-wander_dev}
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}

echo "🌱 Seeding database..."

for seed_file in ../backend/seeds/*.sql; do
    if [ -f "$seed_file" ]; then
        echo "  Running $(basename $seed_file)..."
        PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -f "$seed_file" > /dev/null
    fi
done

echo "✅ Database seeded successfully!"

