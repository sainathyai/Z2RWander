# Operations Guide

Complete reference for all Make commands and operations.

## Make Commands Reference

### Service Management

| Command | Description | Example |
|---------|-------------|---------|
| `make dev` | Start all services | `make dev PROFILE=full` |
| `make down` | Stop all services | `make down` |
| `make restart` | Restart all services | `make restart` |
| `make status` | Check service health | `make status` |
| `make ps` | Alias for status | `make ps` |
| `make top` | Show resource usage | `make top` |
| `make logs` | View service logs | `make logs api` |

### Individual Service Control

| Command | Description |
|---------|-------------|
| `make start-api` | Start backend only |
| `make stop-api` | Stop backend only |
| `make restart-api` | Restart backend only |
| `make start-frontend` | Start frontend only |
| `make stop-frontend` | Stop frontend only |
| `make restart-frontend` | Restart frontend only |
| `make restart-db` | Restart database (with warning) |
| `make restart-redis` | Restart Redis |

### Building

| Command | Description |
|---------|-------------|
| `make rebuild` | Rebuild all containers |
| `make rebuild-api` | Rebuild backend container |
| `make rebuild-frontend` | Rebuild frontend container |

### Shell Access

| Command | Description |
|---------|-------------|
| `make shell-api` | Open shell in backend container |
| `make shell-db` | Open PostgreSQL console |
| `make shell-redis` | Open Redis CLI |

### Database Operations

| Command | Description | Example |
|---------|-------------|---------|
| `make seed` | Seed database with sample data | `make seed` |
| `make reset-db` | Reset database (drop + recreate + seed) | `make reset-db` |
| `make db-backup` | Create database backup | `make db-backup` |
| `make db-restore` | Restore from backup | `make db-restore BACKUP=backups/backup.sql` |
| `make db-snapshot` | Create named snapshot | `make db-snapshot NAME=before-refactor` |
| `make snapshots` | List all snapshots | `make snapshots` |
| `make restore` | Restore from snapshot | `make restore NAME=before-refactor` |
| `make db-migrate` | Run database migrations | `make db-migrate` |
| `make db-console` | Open PostgreSQL console | `make db-console` |
| `make migration` | Create new migration | `make migration NAME=add_users` |

### Code Quality

| Command | Description |
|---------|-------------|
| `make lint` | Run all linters |
| `make lint-fix` | Auto-fix linting issues |
| `make format` | Format code with Prettier |

### Testing

| Command | Description |
|---------|-------------|
| `make test` | Run all tests |
| `make test-api` | Run backend tests only |
| `make test-frontend` | Run frontend tests only |
| `make test-integration` | Run integration tests |
| `make test-e2e` | Run end-to-end tests |

### Maintenance

| Command | Description |
|---------|-------------|
| `make clean` | Remove containers and volumes |
| `make clean-all` | Remove containers, volumes, and images |
| `make check-deps` | Verify Docker installation |

### Help

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |

## Environment Profiles

### Minimal Profile
```bash
make dev PROFILE=minimal
```
**Services:** Frontend only  
**Use case:** Frontend-only development

### Backend Profile
```bash
make dev PROFILE=backend
```
**Services:** Backend + PostgreSQL + Redis  
**Use case:** Backend API development

### Full Profile (Default)
```bash
make dev PROFILE=full
# or
make dev
```
**Services:** All services  
**Use case:** Full-stack development

## Configuration Reference

### Environment Variables

Create a `.env` file in the project root to override defaults:

```env
# API Configuration
API_PORT=8080
API_HOST=0.0.0.0
NODE_ENV=development

# Database Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_USER=wander
POSTGRES_PASSWORD=dev_password_123
POSTGRES_DB=wander_dev

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# Frontend Configuration
VITE_PORT=3000
VITE_API_URL=http://backend:8080
```

### Port Reference

| Service | Default Port | Environment Variable |
|---------|--------------|---------------------|
| Frontend | 3000 | `VITE_PORT` |
| Backend API | 8080 | `API_PORT` |
| PostgreSQL | 5432 | `POSTGRES_PORT` |
| Redis | 6379 | `REDIS_PORT` |

## Common Workflows

### Daily Development

```bash
# Start environment
make dev

# View logs
make logs

# Make changes to code (hot reload works)

# Check status
make status

# Stop when done
make down
```

### Adding a New Feature

```bash
# Start environment
make dev

# Create migration if needed
make migration NAME=add_feature_table

# Develop feature
# ... edit code ...

# Test
make test

# Commit
git add .
git commit -m "feat: add new feature"
```

### Database Changes

```bash
# Create snapshot before changes
make db-snapshot NAME=before-schema-change

# Create migration
make migration NAME=update_schema

# Apply migration
make db-migrate

# Test changes
make shell-db
# ... run queries ...

# If something goes wrong, restore
make restore NAME=before-schema-change
```

### Debugging

```bash
# View logs
make logs api

# Access service shell
make shell-api

# Check database
make shell-db

# Check Redis
make shell-redis

# View resource usage
make top
```

### Clean Start

```bash
# Stop everything
make down

# Remove all data
make clean

# Start fresh
make dev

# Seed database
make seed
```

## Advanced Operations

### Custom Docker Compose Files

You can use custom compose files:

```bash
cd infrastructure
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```

### Direct Docker Commands

If you need direct Docker access:

```bash
# List containers
docker ps

# View logs
docker logs wander-backend

# Execute command in container
docker exec -it wander-backend sh

# View container stats
docker stats
```

### Volume Management

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect infrastructure_postgres_data

# Remove volume (⚠️ deletes data)
docker volume rm infrastructure_postgres_data
```

### Network Management

```bash
# List networks
docker network ls

# Inspect network
docker network inspect infrastructure_wander-network

# Remove network
docker network rm infrastructure_wander-network
```

## Troubleshooting Commands

### Check Service Health

```bash
# Quick status
make status

# Detailed health check
curl http://localhost:8080/health

# Database health
make shell-db
SELECT 1;

# Redis health
make shell-redis
PING
```

### View Detailed Logs

```bash
# All services
make logs

# Specific service
make logs api
make logs frontend
make logs postgres
make logs redis

# Follow logs (real-time)
cd infrastructure
docker-compose logs -f api
```

### Resource Monitoring

```bash
# Current resource usage
make top

# Detailed stats
docker stats

# Container resource limits
docker inspect wander-backend | grep -i memory
```

## Best Practices

1. **Always use Make commands** - They handle cross-platform differences
2. **Create snapshots before major changes** - Easy rollback
3. **Use profiles** - Only run what you need
4. **Check status regularly** - Catch issues early
5. **Clean up periodically** - Free disk space
6. **Backup before destructive operations** - Safety first

## Getting Help

- Run `make help` for command list
- Check [Troubleshooting Guide](TROUBLESHOOTING.md)
- Review [FAQ](FAQ.md)
- Open an issue on GitHub

