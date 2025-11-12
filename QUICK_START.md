# Quick Start Guide

## Single Command to Start Everything

```bash
make dev
```

That's it! This single command will:
- Check Docker is installed and running
- Build all Docker images
- Start all services (PostgreSQL, Redis, Backend, Frontend)
- Wait for services to be healthy
- Show status of all services

## Single Command to Tear Everything Down

```bash
make teardown
```

or

```bash
make clean-all
```

This will:
- Stop all containers
- Remove all containers
- Remove all volumes (database data, Redis data)
- Remove all images
- Remove networks
- Complete cleanup

## Alternative: Using Docker Compose Directly

If you don't have `make` installed:

**Start everything:**
```bash
cd infrastructure && docker-compose up -d
```

**Tear everything down:**
```bash
cd infrastructure && docker-compose down -v --rmi all --remove-orphans
```

## What Gets Started

When you run `make dev`, the following services start:

1. **PostgreSQL** - Database on port 5432
2. **Redis** - Cache on port 6379
3. **Backend API** - Node.js API on port 8080
4. **Frontend** - React app on port 3000

## Access Points

Once started, access:
- **Frontend Dashboard:** http://localhost:3000
- **Backend API:** http://localhost:8080
- **Health Check:** http://localhost:8080/health
- **API Dashboard:** http://localhost:8080/dashboard

## Troubleshooting

If something goes wrong:

1. **Complete reset:**
   ```bash
   make teardown
   make dev
   ```

2. **Check service status:**
   ```bash
   make status
   ```

3. **View logs:**
   ```bash
   make logs
   ```

## Next Steps

After `make dev` completes:
1. Open http://localhost:3000 in your browser
2. See the setup progress and all installed packages
3. Start developing!

