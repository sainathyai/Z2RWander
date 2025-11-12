# Frequently Asked Questions

## General Questions

### What is this project?

The Wander Zero-to-Running Developer Environment is a containerized development setup that allows developers to get a full-stack application (frontend, backend, database, cache) running with a single command.

### Why use Docker?

Docker ensures:
- **Consistency:** Same environment for all developers
- **Isolation:** No conflicts with system packages
- **Speed:** Quick setup and teardown
- **Reproducibility:** Works the same on Windows, macOS, and Linux

### Do I need to know Docker?

No! The Makefile abstracts away Docker complexity. Just run `make dev` and you're done.

### What if I don't have Make?

You can use Docker Compose directly:
```bash
cd infrastructure
docker-compose up -d
```

Or install Make:
- **Windows:** `choco install make` or use Git Bash
- **macOS:** `xcode-select --install`
- **Linux:** `sudo apt-get install make`

## Setup Questions

### How long does setup take?

- **First time:** 5-10 minutes (downloading images)
- **Subsequent:** 30-60 seconds

### What are the system requirements?

- **RAM:** 4GB minimum, 8GB recommended
- **Disk:** 10GB free space
- **OS:** Windows 10+, macOS 10.15+, or Linux

### Can I use this on Windows?

Yes! Fully supported on Windows 10/11 with Docker Desktop.

### Can I use this on M1/M2 Macs?

Yes! Docker Desktop for Mac supports Apple Silicon natively.

## Usage Questions

### How do I start developing?

1. `make dev` - Start all services
2. Edit code in `frontend/` or `backend/`
3. Changes hot-reload automatically
4. Visit http://localhost:3000

### How do I stop everything?

```bash
make down
```

### How do I restart a single service?

```bash
make restart-api      # Backend
make restart-frontend # Frontend
make restart-db       # Database
```

### Can I run just the frontend?

Yes! Use the minimal profile:
```bash
make dev PROFILE=minimal
```

### Can I run just the backend?

Yes! Use the backend profile:
```bash
make dev PROFILE=backend
```

## Database Questions

### How do I reset the database?

```bash
make reset-db
```

**Warning:** This deletes all data!

### How do I backup the database?

```bash
make db-backup
```

Backups are saved in `backups/` directory.

### How do I restore from backup?

```bash
make db-restore BACKUP=backups/backup_20240101_120000.sql
```

### How do I create a migration?

```bash
make migration NAME=add_user_roles
```

This creates a file in `backend/migrations/`.

### How do I seed the database?

```bash
make seed
```

## Development Questions

### How do I add a new API endpoint?

1. Create route file: `backend/src/routes/my-route.ts`
2. Register in `backend/src/index.ts`
3. Restart: `make restart-api`

See [Developer Guide](DEVELOPER_GUIDE.md) for details.

### How do I add a new React component?

1. Create component: `frontend/src/components/MyComponent.tsx`
2. Import and use in your code
3. Hot reload will pick it up automatically!

### How do I change environment variables?

Create a `.env` file in the project root:
```env
API_PORT=8081
POSTGRES_PASSWORD=my_password
```

### How do I view logs?

```bash
make logs              # All services
make logs api          # Backend only
make logs frontend     # Frontend only
```

### How do I debug?

1. **View logs:** `make logs`
2. **Shell access:** `make shell-api` (backend) or `make shell-db` (database)
3. **Check status:** `make status`

## Troubleshooting Questions

### Services won't start. What do I do?

1. Check Docker is running: `docker ps`
2. Check for port conflicts: `make check-deps`
3. View logs: `make logs`
4. Try clean start: `make clean && make dev`

### Port already in use. How do I fix it?

Change ports in `.env`:
```env
API_PORT=8081
VITE_PORT=3001
POSTGRES_PORT=5433
```

### Database connection failed. What's wrong?

1. Check database is running: `make status`
2. Verify credentials in `.env`
3. Reset database: `make reset-db`

### Frontend shows blank page. Why?

1. Check frontend is running: `make status`
2. Check logs: `make logs frontend`
3. Rebuild: `make rebuild-frontend`

### Changes not showing up. What's wrong?

1. Check hot reload is working (should see Vite HMR messages)
2. Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)
3. Restart service: `make restart-frontend` or `make restart-api`

## Performance Questions

### It's slow. How do I speed it up?

1. **Increase Docker resources:**
   - Docker Desktop → Settings → Resources
   - Increase CPU/Memory

2. **Use minimal profile:**
   ```bash
   make dev PROFILE=minimal
   ```

3. **Clean up:**
   ```bash
   docker system prune
   ```

### How much disk space does it use?

- **Images:** ~2-3 GB
- **Volumes:** ~500 MB - 2 GB (depends on data)
- **Total:** ~3-5 GB

### How much RAM does it use?

- **Idle:** ~500 MB - 1 GB
- **Active development:** ~1-2 GB

## Advanced Questions

### Can I use this in production?

No! This is designed for local development only. For production:
- Use managed database services
- Implement proper security
- Use Kubernetes for orchestration
- Add monitoring and logging

### Can I add more services?

Yes! See [Developer Guide](DEVELOPER_GUIDE.md) for instructions.

### Can I customize the setup?

Yes! You can:
- Modify `docker-compose.yml`
- Add environment variables
- Create custom profiles
- Add new services

### How do I update dependencies?

```bash
cd backend && npm update
cd ../frontend && npm update
make rebuild
```

### Can I use a different database?

Yes! Modify `docker-compose.yml` to use a different image. You'll also need to update connection code in `backend/src/db/client.ts`.

## Still Have Questions?

- Check [Troubleshooting Guide](TROUBLESHOOTING.md)
- Review [Architecture Documentation](ARCHITECTURE.md)
- Open an issue on GitHub

