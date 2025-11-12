# Quick Start Guide

Get your Wander development environment up and running in 5 minutes!

## Prerequisites

Before you begin, ensure you have the following installed:

- **Docker Desktop** (v20.10+) - [Download](https://www.docker.com/products/docker-desktop)
- **Docker Compose** (v2.0+) - Usually included with Docker Desktop
- **Make** (optional but recommended)
  - **Windows:** Install via [Chocolatey](https://chocolatey.org/) (`choco install make`) or use Git Bash
  - **macOS:** `xcode-select --install`
  - **Linux:** `sudo apt-get install make` (Ubuntu/Debian) or `sudo yum install make` (RHEL/CentOS)
- **Git** - [Download](https://git-scm.com/downloads)

## First-Time Setup

### 1. Clone the Repository

```bash
git clone git@github.com:sainathyai/Z2RWander.git
cd Z2RWander
```

### 2. Start the Environment

```bash
make dev
```

That's it! The first run will:
- Download Docker images (~5-10 minutes)
- Build containers
- Start all services
- Seed the database

### 3. Verify Everything Works

Open your browser and visit:
- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8080
- **Health Check:** http://localhost:8080/health
- **Dashboard:** http://localhost:8080/dashboard

### 4. Check Service Status

```bash
make status
```

You should see all services as "healthy" (green).

## Daily Workflow

### Start Development

```bash
make dev
```

### Stop Services

```bash
make down
```

### View Logs

```bash
make logs          # All services
make logs api      # Backend only
make logs frontend # Frontend only
```

### Restart a Service

```bash
make restart-api      # Restart backend
make restart-frontend # Restart frontend
```

## Common Commands

| Command | Description |
|---------|-------------|
| `make dev` | Start all services |
| `make down` | Stop all services |
| `make status` | Check service health |
| `make logs` | View service logs |
| `make seed` | Seed database with sample data |
| `make reset-db` | Reset database (drop + recreate + seed) |
| `make shell-api` | Open shell in backend container |
| `make shell-db` | Open PostgreSQL console |
| `make help` | Show all available commands |

## Environment Profiles

Choose what to run based on your needs:

```bash
make dev PROFILE=minimal  # Frontend only
make dev PROFILE=backend  # Backend + DB + Redis (no frontend)
make dev PROFILE=full     # Everything (default)
```

## Troubleshooting

### Services Won't Start

1. **Check Docker is running:**
   ```bash
   docker ps
   ```

2. **Check for port conflicts:**
   ```bash
   make check-deps
   ```

3. **View detailed logs:**
   ```bash
   make logs
   ```

### Database Connection Issues

1. **Reset the database:**
   ```bash
   make reset-db
   ```

2. **Check database logs:**
   ```bash
   make logs db
   ```

### Port Already in Use

Edit `.env` file (create if it doesn't exist) to change ports:

```env
API_PORT=8081
VITE_PORT=3001
POSTGRES_PORT=5433
REDIS_PORT=6380
```

### Clean Start

If everything seems broken:

```bash
make clean      # Remove containers and volumes
make dev        # Start fresh
```

## Next Steps

- Read the [Architecture Documentation](ARCHITECTURE.md)
- Check the [Developer Guide](DEVELOPER_GUIDE.md)
- Review [Troubleshooting Guide](TROUBLESHOOTING.md)

## Getting Help

- Check the [FAQ](FAQ.md)
- Review [Known Issues](KNOWN_ISSUES.md)
- Open an issue on GitHub

