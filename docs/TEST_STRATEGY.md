# Test Strategy

## Overview

This document outlines the comprehensive testing strategy for the Wander Zero-to-Running Developer Environment.

## Testing Objectives

1. **Verify Setup Works:** Ensure `make dev` successfully starts all services
2. **Validate Service Health:** Confirm all services are healthy and communicating
3. **Test Cross-Platform:** Verify compatibility on Windows, macOS, and Linux
4. **Performance Validation:** Ensure startup times meet targets
5. **Regression Prevention:** Catch breaking changes early

## Test Types

### 1. Smoke Tests
**Purpose:** Quick validation that core functionality works  
**Frequency:** After every change, before commits  
**Duration:** < 1 minute  
**Script:** `scripts/smoke-test.sh`

**Tests:**
- Backend health endpoint responds
- Backend API endpoints work
- Dashboard endpoint accessible
- Frontend loads (if running)
- Database connection works
- Redis connection works

### 2. Integration Tests
**Purpose:** Verify services communicate correctly  
**Frequency:** Before merging PRs  
**Duration:** 2-5 minutes  
**Script:** `make test-integration` (to be implemented)

**Tests:**
- Frontend can call backend API
- Backend can query database
- Backend can use Redis cache
- Health checks propagate correctly
- Service dependencies work

### 3. Performance Tests
**Purpose:** Validate startup times and resource usage  
**Frequency:** Weekly, after major changes  
**Duration:** 5-10 minutes  
**Script:** `scripts/benchmark.sh`

**Metrics:**
- First-time setup time (target: < 10 minutes)
- Subsequent startup time (target: < 2 minutes)
- Rebuild time (target: < 1 minute)
- Memory usage (target: < 2 GB)
- CPU usage (target: < 50% idle)

### 4. End-to-End Tests
**Purpose:** Test complete user workflows  
**Frequency:** Before releases  
**Duration:** 10-15 minutes  
**Script:** `make test-e2e` (to be implemented)

**Scenarios:**
- Fresh clone → `make dev` → verify all services
- Code change → hot reload works
- Database migration → schema updates
- Snapshot → restore workflow
- Profile switching (minimal/backend/full)

### 5. Cross-Platform Tests
**Purpose:** Ensure compatibility across operating systems  
**Frequency:** Before releases  
**Duration:** 30-60 minutes  
**Platform:** GitHub Actions (Windows, macOS, Linux)

**Tests:**
- Windows 10/11 compatibility
- macOS Intel/Apple Silicon compatibility
- Linux (Ubuntu, Fedora) compatibility
- Docker Desktop vs native Docker

### 6. Regression Tests
**Purpose:** Prevent breaking changes  
**Frequency:** Continuous (CI/CD)  
**Duration:** 5-10 minutes  
**Platform:** GitHub Actions

**Tests:**
- All smoke tests pass
- All integration tests pass
- No new linting errors
- Documentation builds successfully

## Test Execution

### Local Testing

#### Quick Smoke Test
```bash
make smoke-test
```

#### Full Test Suite
```bash
# Start services
make dev

# Run smoke tests
make smoke-test

# Run benchmarks
make benchmark

# Run integration tests (when implemented)
make test-integration
```

#### Manual Testing Checklist
- [ ] `make dev` starts all services
- [ ] All services show as healthy in `make status`
- [ ] Frontend accessible at http://localhost:3000
- [ ] Backend health check works: http://localhost:8080/health
- [ ] API endpoints respond: http://localhost:8080/api/status
- [ ] Dashboard works: http://localhost:8080/dashboard
- [ ] Database connection works: `make shell-db`
- [ ] Redis connection works: `make shell-redis`
- [ ] Hot reload works (edit code, see changes)
- [ ] `make down` stops all services cleanly

### CI/CD Testing

GitHub Actions automatically runs:
- Docker Compose config validation
- Service build verification
- Health check validation
- Cross-platform compatibility

**Workflow:** `.github/workflows/test.yml`

## Test Environments

### Development
- **Purpose:** Local development testing
- **Setup:** `make dev`
- **Data:** Sample/seed data
- **Isolation:** Docker containers

### CI/CD
- **Purpose:** Automated testing
- **Setup:** GitHub Actions
- **Data:** Fresh install each run
- **Isolation:** Ephemeral containers

## Test Data

### Seed Data
- **Location:** `backend/seeds/`
- **Purpose:** Provide realistic test data
- **Usage:** `make seed`

### Test Fixtures
- **Location:** `backend/tests/fixtures/` (to be created)
- **Purpose:** Isolated test data
- **Usage:** Test-specific data sets

## Success Criteria

### Smoke Tests
- ✅ All endpoints respond with 200 OK
- ✅ All services show as healthy
- ✅ No connection errors

### Performance Tests
- ✅ First-time setup: < 10 minutes
- ✅ Subsequent startup: < 2 minutes
- ✅ Rebuild: < 1 minute
- ✅ Memory: < 2 GB total
- ✅ CPU: < 50% idle

### Integration Tests
- ✅ Frontend → Backend communication works
- ✅ Backend → Database queries succeed
- ✅ Backend → Redis operations work
- ✅ Health checks accurate

## Test Reporting

### Local Reports
- Console output with colored results
- Exit codes (0 = success, 1 = failure)
- Detailed error messages

### CI/CD Reports
- GitHub Actions status badges
- Test result summaries
- Failure notifications

### Performance Reports
- Startup time metrics
- Resource usage graphs
- Trend analysis (over time)

## Continuous Improvement

### Test Coverage Goals
- **Current:** ~60% (smoke tests + basic integration)
- **Target:** 80%+ (comprehensive E2E + unit tests)

### Areas for Enhancement
1. Unit tests for backend routes
2. Frontend component tests
3. Database migration tests
4. Error scenario testing
5. Load testing
6. Security testing

## Troubleshooting Test Failures

### Common Issues

1. **Services not starting**
   - Check Docker is running
   - Verify ports are available
   - Check logs: `make logs`

2. **Connection timeouts**
   - Wait longer for services to start
   - Check service health: `make status`
   - Verify network connectivity

3. **Port conflicts**
   - Change ports in `.env`
   - Stop conflicting services
   - Use `make check-deps`

### Debug Commands
```bash
# Check service status
make status

# View logs
make logs

# Check Docker
docker ps
docker-compose ps

# Test individual services
curl http://localhost:8080/health
make shell-db
make shell-redis
```

## Test Maintenance

### Regular Tasks
- **Weekly:** Run full test suite
- **Before PRs:** Run smoke tests
- **Before Releases:** Run all tests + benchmarks
- **Monthly:** Review and update test strategy

### Test Updates
- Update tests when adding new features
- Add tests for bug fixes
- Remove obsolete tests
- Improve test coverage

## References

- [Smoke Test Script](../scripts/smoke-test.sh)
- [Benchmark Script](../scripts/benchmark.sh)
- [CI/CD Workflow](../.github/workflows/test.yml)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
