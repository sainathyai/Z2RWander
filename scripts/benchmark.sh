#!/bin/sh
# Performance benchmarking script

set -e

echo "🚀 Starting Performance Benchmark..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Benchmark functions
benchmark_startup() {
    echo "${BLUE}📊 Benchmarking Startup Time...${NC}"
    
    # Clean start
    echo "Cleaning up..."
    cd infrastructure
    docker-compose down -v > /dev/null 2>&1 || true
    
    # Measure startup time
    START_TIME=$(date +%s)
    docker-compose up -d > /dev/null 2>&1
    
    # Wait for services to be healthy
    echo "Waiting for services to be healthy..."
    sleep 30
    
    # Check health
    MAX_WAIT=120
    ELAPSED=0
    while [ $ELAPSED -lt $MAX_WAIT ]; do
        if curl -f http://localhost:8080/health > /dev/null 2>&1; then
            END_TIME=$(date +%s)
            DURATION=$((END_TIME - START_TIME))
            echo "${GREEN}✅ Services started in ${DURATION} seconds${NC}"
            return
        fi
        sleep 5
        ELAPSED=$((ELAPSED + 5))
    done
    
    echo "${YELLOW}⚠️  Services did not become healthy within ${MAX_WAIT} seconds${NC}"
}

benchmark_memory() {
    echo ""
    echo "${BLUE}📊 Benchmarking Memory Usage...${NC}"
    
    cd infrastructure
    docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.MemPerc}}" | grep wander || true
}

benchmark_disk() {
    echo ""
    echo "${BLUE}📊 Benchmarking Disk Usage...${NC}"
    
    echo "Docker images:"
    docker images | grep -E "wander|postgres|redis|node" | awk '{print $1, $2, $5}' || true
    
    echo ""
    echo "Docker volumes:"
    docker volume ls | grep infrastructure || true
}

benchmark_rebuild() {
    echo ""
    echo "${BLUE}📊 Benchmarking Rebuild Time...${NC}"
    
    cd infrastructure
    
    # Rebuild backend
    START_TIME=$(date +%s)
    docker-compose build --no-cache backend > /dev/null 2>&1
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    echo "${GREEN}✅ Backend rebuild: ${DURATION} seconds${NC}"
    
    # Rebuild frontend
    START_TIME=$(date +%s)
    docker-compose build --no-cache frontend > /dev/null 2>&1
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    echo "${GREEN}✅ Frontend rebuild: ${DURATION} seconds${NC}"
}

# Run benchmarks
benchmark_startup
benchmark_memory
benchmark_disk
benchmark_rebuild

echo ""
echo "${GREEN}✅ Benchmark complete!${NC}"

