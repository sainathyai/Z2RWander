# Troubleshooting Guide

Common issues and their solutions.

## Services Won't Start

### Issue: Docker not running

**Symptoms:**
- `Error: Cannot connect to the Docker daemon`
- `docker: command not found`

**Solution:**
1. Start Docker Desktop
2. Wait for it to fully start (whale icon in system tray)
3. Verify: `docker ps`

### Issue: Port already in use

**Symptoms:**
- `Error: bind: address already in use`
- `Port 3000 is already allocated`

**Solution:**
1. Find what's using the port:
   ```bash
   # Windows
   netstat -ano | findstr :3000
   
   # macOS/Linux
   lsof -i :3000
   ```

2. Stop the conflicting service or change ports in `.env`:
   ```env
   VITE_PORT=3001
   API_PORT=8081
   ```

### Issue: Out of disk space

**Symptoms:**
- `no space left on device`
- Docker build fails

**Solution:**
```bash
# Clean up Docker
docker system prune -a --volumes

# Check disk space
df -h  # Linux/macOS
```

## Database Issues

### Issue: Cannot connect to database

**Symptoms:**
- `Error: connect ECONNREFUSED`
- `FATAL: password authentication failed`

**Solution:**
1. Check database is running:
   ```bash
   make status
   ```

2. Verify credentials in `.env`:
   ```env
   POSTGRES_USER=wander
   POSTGRES_PASSWORD=dev_password_123
   POSTGRES_DB=wander_dev
   ```

3. Reset database:
   ```bash
   make reset-db
   ```

### Issue: Migration failed

**Symptoms:**
- `ERROR: relation already exists`
- `ERROR: syntax error`

**Solution:**
1. Check migration file syntax
2. Verify migration hasn't been run:
   ```bash
   make shell-db
   \dt  # List tables
   ```

3. Manually fix if needed:
   ```bash
   make shell-db
   # Run SQL commands manually
   ```

### Issue: Database is corrupted

**Symptoms:**
- `FATAL: database files are incompatible`
- Queries return unexpected errors

**Solution:**
```bash
# Backup first (if possible)
make db-backup

# Reset database
make reset-db
```

## Frontend Issues

### Issue: Frontend won't load

**Symptoms:**
- Blank page
- `ERR_CONNECTION_REFUSED`
- `Cannot GET /`

**Solution:**
1. Check frontend is running:
   ```bash
   make status
   ```

2. Check logs:
   ```bash
   make logs frontend
   ```

3. Rebuild frontend:
   ```bash
   make rebuild-frontend
   ```

### Issue: API calls fail

**Symptoms:**
- `Network Error`
- `CORS error`
- `404 Not Found`

**Solution:**
1. Verify backend is running:
   ```bash
   curl http://localhost:8080/health
   ```

2. Check `VITE_API_URL` in frontend:
   ```typescript
   // Should be empty or http://backend:8080 in Docker
   const API_URL = import.meta.env.VITE_API_URL || '';
   ```

3. Check Vite proxy config in `frontend/vite.config.ts`

## Backend Issues

### Issue: Backend won't start

**Symptoms:**
- `Error: listen EADDRINUSE`
- `Cannot find module`

**Solution:**
1. Check logs:
   ```bash
   make logs api
   ```

2. Rebuild backend:
   ```bash
   make rebuild-api
   ```

3. Check for syntax errors:
   ```bash
   cd backend && npm run type-check
   ```

### Issue: Database connection timeout

**Symptoms:**
- `Connection timeout`
- `ETIMEDOUT`

**Solution:**
1. Verify database is healthy:
   ```bash
   make status
   ```

2. Check network:
   ```bash
   make shell-api
   ping postgres
   ```

3. Increase timeout in `backend/src/db/client.ts`

## Redis Issues

### Issue: Cannot connect to Redis

**Symptoms:**
- `Error: connect ECONNREFUSED`
- `Redis connection failed`

**Solution:**
1. Check Redis is running:
   ```bash
   make status
   ```

2. Test connection:
   ```bash
   make shell-redis
   PING  # Should return PONG
   ```

3. Restart Redis:
   ```bash
   make restart-redis
   ```

## Build Issues

### Issue: Build fails with npm errors

**Symptoms:**
- `npm ERR!`
- `Cannot find module`

**Solution:**
1. Clear npm cache:
   ```bash
   docker system prune -a
   ```

2. Rebuild without cache:
   ```bash
   make rebuild
   ```

3. Check `package.json` for errors

### Issue: TypeScript errors

**Symptoms:**
- `Type error: ...`
- `Cannot find name`

**Solution:**
1. Check TypeScript config:
   ```bash
   cd backend && npm run type-check
   cd ../frontend && npm run type-check
   ```

2. Install missing types:
   ```bash
   npm install --save-dev @types/package-name
   ```

## Performance Issues

### Issue: Slow startup

**Symptoms:**
- Services take > 5 minutes to start
- High CPU usage

**Solution:**
1. Check Docker resources:
   - Docker Desktop → Settings → Resources
   - Increase CPU/Memory allocation

2. Clean up:
   ```bash
   docker system prune
   ```

3. Use minimal profile:
   ```bash
   make dev PROFILE=minimal
   ```

### Issue: High memory usage

**Symptoms:**
- System becomes slow
- Out of memory errors

**Solution:**
1. Check resource usage:
   ```bash
   make top
   ```

2. Stop unused services:
   ```bash
   make stop-frontend  # If not needed
   ```

3. Increase Docker memory limit in Docker Desktop settings

## Windows-Specific Issues

### Issue: Line ending errors

**Symptoms:**
- `warning: LF will be replaced by CRLF`
- Scripts fail with `\r` errors

**Solution:**
```bash
git config --global core.autocrlf true
```

### Issue: Path too long

**Symptoms:**
- `Filename too long`
- Build fails

**Solution:**
1. Enable long paths in Windows:
   ```powershell
   New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
   ```

2. Restart computer

### Issue: Permission denied

**Symptoms:**
- `Permission denied`
- Cannot access files

**Solution:**
1. Run terminal as Administrator
2. Check file permissions
3. Exclude project folder from antivirus scanning

## macOS-Specific Issues

### Issue: M1/M2 compatibility

**Symptoms:**
- `exec format error`
- Services won't start

**Solution:**
1. Use ARM64 images:
   ```dockerfile
   FROM --platform=linux/arm64 node:20-alpine
   ```

2. Or use Rosetta 2 (automatic in Docker Desktop)

## Linux-Specific Issues

### Issue: Permission denied for Docker

**Symptoms:**
- `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Issue: SELinux blocking

**Symptoms:**
- `Permission denied`
- Volume mounts fail

**Solution:**
```bash
# Temporarily disable (not recommended for production)
sudo setenforce 0
```

## Still Having Issues?

1. **Check logs:**
   ```bash
   make logs
   ```

2. **Verify environment:**
   ```bash
   make check-deps
   ```

3. **Clean start:**
   ```bash
   make clean
   make dev
   ```

4. **Check GitHub Issues:**
   - Search for similar issues
   - Open a new issue with:
     - Error messages
     - Steps to reproduce
     - System information (`docker --version`, OS version)

5. **Get system info:**
   ```bash
   docker --version
   docker-compose --version
   make status
   ```

