#!/bin/sh
# Smoke tests - quick validation that everything works

set -e

echo "🧪 Running Smoke Tests..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0

# Test function
test_endpoint() {
    URL=$1
    NAME=$2
    
    if curl -f -s "$URL" > /dev/null 2>&1; then
        echo "${GREEN}✅ ${NAME}${NC}"
        return 0
    else
        echo "${RED}❌ ${NAME}${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Test backend health
echo "Testing Backend Health..."
test_endpoint "http://localhost:8080/health" "Backend Health Check"

# Test backend API
echo ""
echo "Testing Backend API..."
test_endpoint "http://localhost:8080/api/status" "Backend API Status"

# Test dashboard
echo ""
echo "Testing Dashboard..."
test_endpoint "http://localhost:8080/dashboard" "Dashboard Endpoint"

# Test frontend (if running)
echo ""
echo "Testing Frontend..."
if curl -f -s "http://localhost:3000" > /dev/null 2>&1; then
    echo "${GREEN}✅ Frontend${NC}"
else
    echo "${YELLOW}⚠️  Frontend not running (may be expected if using backend profile)${NC}"
fi

# Test database connection
echo ""
echo "Testing Database Connection..."
if docker exec wander-postgres psql -U wander -d wander_dev -c "SELECT 1" > /dev/null 2>&1; then
    echo "${GREEN}✅ Database Connection${NC}"
else
    echo "${RED}❌ Database Connection${NC}"
    FAILED=$((FAILED + 1))
fi

# Test Redis connection
echo ""
echo "Testing Redis Connection..."
if docker exec wander-redis redis-cli PING > /dev/null 2>&1; then
    echo "${GREEN}✅ Redis Connection${NC}"
else
    echo "${RED}❌ Redis Connection${NC}"
    FAILED=$((FAILED + 1))
fi

# Summary
echo ""
if [ $FAILED -eq 0 ]; then
    echo "${GREEN}✅ All smoke tests passed!${NC}"
    exit 0
else
    echo "${RED}❌ ${FAILED} test(s) failed${NC}"
    exit 1
fi

