# Quick Start Guide

Get your Wander Developer Environment up and running in under 10 minutes!

## Prerequisites

- **Docker Desktop** installed and running
- **Git** installed
- **Make** utility (or use Docker Compose directly)

## Setup Steps

### 1. Clone the Repository

```bash
git clone git@github.com:sainathyai/Z2RWander.git
cd Z2RWander
```

### 2. Start the Environment

```bash
make dev
```

That's it! 🎉

The command will:
- Pull Docker images (first time only)
- Start PostgreSQL database
- Start Redis cache
- Start Backend API
- Start Frontend application
- Run database migrations

### 3. Access the Services

Once everything is running, you can access:

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8080
- **API Health Check:** http://localhost:8080/health
- **PostgreSQL:** localhost:5432
- **Redis:** localhost:6379

### 4. Verify Everything Works

Open your browser and go to http://localhost:3000. You should see the Wander Developer Environment dashboard showing the status of all services.

## Common Commands

```bash
# Start all services
make dev

# Stop all services
make down

# View logs from all services
make logs

# Check service status
make status

# Clean everything (removes volumes)
make clean

# Show help
make help
```

## Troubleshooting

### Port Already in Use

If you get port conflicts, you can change ports in `.env` file:

```env
API_PORT=8081
VITE_PORT=3001
POSTGRES_PORT=5433
REDIS_PORT=6380
```

### Services Not Starting

1. Check Docker Desktop is running
2. Check logs: `make logs`
3. Check status: `make status`
4. Try cleaning and restarting: `make clean && make dev`

### Database Connection Issues

The backend waits for the database to be healthy before starting. If you see connection errors:

1. Check PostgreSQL is running: `docker ps | grep postgres`
2. Check logs: `docker logs wander-postgres`
3. Verify environment variables in `.env`

## Development Workflow

### Hot Reload

Both frontend and backend support hot reload:
- Edit files in `frontend/src/` - changes appear instantly
- Edit files in `backend/src/` - server auto-restarts

### Database Migrations

Migrations are automatically run when PostgreSQL starts. To add new migrations:

1. Create SQL file in `backend/migrations/`
2. Name it with incrementing number: `002_new_feature.sql`
3. Restart services: `make down && make dev`

### Adding Dependencies

**Frontend:**
```bash
cd frontend
npm install <package-name>
```

**Backend:**
```bash
cd backend
npm install <package-name>
```

Changes are reflected immediately due to volume mounts.

## Next Steps

- Read the [full documentation](docs/README.md)
- Check the [implementation plan](docs/IMPLEMENTATION_PLAN.md)
- Review the [architecture](docs/ARCHITECTURE.md) (coming soon)

## Need Help?

- Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md) (coming soon)
- Review logs: `make logs`
- Check service status: `make status`

---

**Happy Coding! 🚀**

