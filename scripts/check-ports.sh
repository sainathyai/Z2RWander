#!/bin/sh
# Check if required ports are available

set -e

check_port() {
    port=$1
    service=$2
    
    if command -v netstat >/dev/null 2>&1; then
        if netstat -an | grep -q ":$port.*LISTEN"; then
            echo "❌ Port $port is already in use (required by $service)"
            echo "   Please stop the service using this port or change the port in .env"
            return 1
        fi
    elif command -v lsof >/dev/null 2>&1; then
        if lsof -i :$port >/dev/null 2>&1; then
            echo "❌ Port $port is already in use (required by $service)"
            echo "   Please stop the service using this port or change the port in .env"
            return 1
        fi
    fi
    
    echo "✅ Port $port is available ($service)"
    return 0
}

echo "🔍 Checking required ports..."

check_port 3000 "Frontend" || exit 1
check_port 8080 "Backend API" || exit 1
check_port 5432 "PostgreSQL" || exit 1
check_port 6379 "Redis" || exit 1

echo "✅ All required ports are available"

