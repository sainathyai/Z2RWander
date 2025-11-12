# What `make dev` Does - Complete Command Breakdown

This document shows exactly what commands are executed when you run `make dev`.

---

## Overview

When you run `make dev`, it executes the following sequence of commands automatically.

---

## Step-by-Step Execution

### Step 1: Dependency Check (`check-deps`)

```bash
# Check if Docker is installed
command -v docker >/dev/null 2>&1

# Check if Docker is running
docker info >/dev/null 2>&1

# Check if Docker Compose is installed
command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1
```

**What it does:**
- Verifies Docker is installed and accessible
- Verifies Docker daemon is running
- Verifies Docker Compose is available
- Exits with error if any check fails

---

### Step 2: Determine Profile

The command checks for a `PROFILE` environment variable:
- `PROFILE=minimal` → Frontend only
- `PROFILE=backend` → Backend + Database + Redis
- `PROFILE=full` or no profile → All services (default)

---

### Step 3: Start Services (Full Stack - Default)

For the full stack profile, it runs:

```bash
cd infrastructure
docker-compose up -d
```

**This single command triggers:**

#### 3.1. Network Creation
```bash
docker network create infrastructure_wander-network
```

#### 3.2. Volume Creation
```bash
docker volume create infrastructure_postgres_data
docker volume create infrastructure_redis_data
```

#### 3.3. PostgreSQL Service
```bash
# Pull image (if not exists)
docker pull postgres:15-alpine

# Create and start container
docker run -d \
  --name wander-postgres \
  --network infrastructure_wander-network \
  -p 5432:5432 \
  -e POSTGRES_USER=wander \
  -e POSTGRES_PASSWORD=dev_password_123 \
  -e POSTGRES_DB=wander_dev \
  -v infrastructure_postgres_data:/var/lib/postgresql/data \
  -v ../backend/migrations:/docker-entrypoint-initdb.d \
  --health-cmd "pg_isready -U wander" \
  --health-interval 5s \
  --health-timeout 5s \
  --health-retries 5 \
  postgres:15-alpine
```

**What happens:**
- Downloads PostgreSQL 15 Alpine image (~80MB)
- Creates container with database configuration
- Runs health checks every 5 seconds
- Executes migration files from `backend/migrations/` on first start
- Persists data in Docker volume

#### 3.4. Redis Service
```bash
# Pull image (if not exists)
docker pull redis:7-alpine

# Create and start container
docker run -d \
  --name wander-redis \
  --network infrastructure_wander-network \
  -p 6379:6379 \
  -v infrastructure_redis_data:/data \
  --health-cmd "redis-cli ping" \
  --health-interval 5s \
  --health-timeout 3s \
  --health-retries 5 \
  redis:7-alpine
```

**What happens:**
- Downloads Redis 7 Alpine image (~30MB)
- Creates container with cache configuration
- Runs health checks every 5 seconds
- Persists data in Docker volume

#### 3.5. Backend API Service
```bash
# Build Docker image
cd ../backend
docker build -f Dockerfile.dev -t infrastructure-backend:latest .

# Inside Dockerfile.dev, these commands run:
# - FROM node:20-alpine
# - WORKDIR /app
# - COPY package*.json ./
# - RUN npm install (or npm ci if package-lock.json exists)
# - COPY . .
# - EXPOSE 8080
# - CMD ["npm", "run", "dev"]

# Create and start container
docker run -d \
  --name wander-backend \
  --network infrastructure_wander-network \
  -p 8080:8080 \
  -e NODE_ENV=development \
  -e POSTGRES_HOST=postgres \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_USER=wander \
  -e POSTGRES_PASSWORD=dev_password_123 \
  -e POSTGRES_DB=wander_dev \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  -e API_PORT=8080 \
  -e API_HOST=0.0.0.0 \
  -v ../backend:/app \
  -v /app/node_modules \
  --depends-on postgres:service_healthy \
  --depends-on redis:service_healthy \
  infrastructure-backend:latest
```

**What happens:**
- Builds backend Docker image with Node.js 20
- Installs all npm dependencies (Express, pg, redis, TypeScript, etc.)
- Copies source code into container
- Sets up hot reload with volume mounting
- Waits for PostgreSQL and Redis to be healthy
- Runs `npm run dev` which executes `tsx watch src/index.ts`
- Starts Express server on port 8080
- Connects to PostgreSQL and Redis

**Inside the container, these npm commands run:**
```bash
npm install
# Installs: express, pg, redis, cors, dotenv, zod, typescript, tsx, etc.

npm run dev
# Executes: tsx watch src/index.ts
# - Compiles TypeScript
# - Watches for file changes
# - Restarts server on changes (hot reload)
```

#### 3.6. Frontend Service
```bash
# Build Docker image
cd ../frontend
docker build -f Dockerfile.dev -t infrastructure-frontend:latest .

# Inside Dockerfile.dev, these commands run:
# - FROM node:20-alpine
# - WORKDIR /app
# - COPY package*.json ./
# - RUN npm install (or npm ci if package-lock.json exists)
# - COPY . .
# - EXPOSE 3000
# - CMD ["npm", "run", "dev"]

# Create and start container
docker run -d \
  --name wander-frontend \
  --network infrastructure_wander-network \
  -p 3000:3000 \
  -e VITE_API_URL=http://backend:8080 \
  -v ../frontend:/app \
  -v /app/node_modules \
  --depends-on backend \
  infrastructure-frontend:latest
```

**What happens:**
- Builds frontend Docker image with Node.js 20
- Installs all npm dependencies (React, Vite, Tailwind, Axios, etc.)
- Copies source code into container
- Sets up hot reload with volume mounting
- Waits for backend to be ready
- Runs `npm run dev` which executes `vite`
- Starts Vite development server on port 3000
- Proxies API requests to backend service

**Inside the container, these npm commands run:**
```bash
npm install
# Installs: react, react-dom, vite, tailwindcss, axios, typescript, etc.

npm run dev
# Executes: vite
# - Starts Vite dev server
# - Watches for file changes
# - Hot module replacement (HMR)
# - Proxies /api requests to http://backend:8080
```

---

### Step 4: Wait and Check Status

After starting services, the Makefile waits 5 seconds:

```bash
sleep 5
```

Then runs status check:

```bash
cd infrastructure
docker-compose ps
```

**This shows:**
- Container names
- Image names
- Status (Up, Exited, etc.)
- Port mappings
- Health status

---

## Complete Command Sequence (Full Stack)

Here's the complete sequence of commands executed:

```bash
# 1. Check dependencies
command -v docker >/dev/null 2>&1 || { echo "Docker not installed"; exit 1; }
docker info >/dev/null 2>&1 || { echo "Docker not running"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1 || { echo "Docker Compose not installed"; exit 1; }

# 2. Navigate to infrastructure directory
cd infrastructure

# 3. Start all services
docker-compose up -d

# 4. Wait for services
sleep 5

# 5. Check status
docker-compose ps
```

---

## Alternative Profiles

### Minimal Profile (`PROFILE=minimal`)

```bash
cd infrastructure
docker-compose -f docker-compose.minimal.yml up -d
```

**Starts only:**
- Frontend service

### Backend Profile (`PROFILE=backend`)

```bash
cd infrastructure
docker-compose -f docker-compose.backend.yml up -d
```

**Starts:**
- PostgreSQL
- Redis
- Backend API

---

## What Gets Created

After `make dev` completes, you'll have:

### Containers
- `wander-postgres` - PostgreSQL database
- `wander-redis` - Redis cache
- `wander-backend` - Backend API
- `wander-frontend` - Frontend application

### Volumes
- `infrastructure_postgres_data` - Database data
- `infrastructure_redis_data` - Cache data

### Networks
- `infrastructure_wander-network` - Internal network for service communication

### Images
- `postgres:15-alpine` - PostgreSQL image
- `redis:7-alpine` - Redis image
- `infrastructure-backend:latest` - Backend image (built locally)
- `infrastructure-frontend:latest` - Frontend image (built locally)

---

## Time Estimates

- **First run (with downloads):** 5-10 minutes
  - Downloading base images: ~2-3 minutes
  - Building backend image: ~2-3 minutes
  - Building frontend image: ~2-3 minutes
  - Starting services: ~1 minute

- **Subsequent runs:** 1-2 minutes
  - Images already exist
  - Only container startup time

---

## Resource Usage

Approximate resource usage when all services are running:

- **Memory:** ~1.5-2GB
  - PostgreSQL: ~100MB
  - Redis: ~50MB
  - Backend: ~200MB
  - Frontend: ~300MB
  - Docker overhead: ~500MB

- **Disk Space:** ~2-3GB
  - Images: ~1.5GB
  - Volumes: ~500MB (grows with data)
  - Containers: ~500MB

- **CPU:** Minimal when idle, spikes during builds/compilation

---

## Manual Execution

If you want to run these commands manually (without Make):

```bash
# 1. Check Docker
docker --version
docker-compose --version
docker ps

# 2. Navigate to infrastructure
cd infrastructure

# 3. Start services
docker-compose up -d

# 4. Check status
docker-compose ps

# 5. View logs
docker-compose logs -f

# 6. Stop services
docker-compose down
```

---

## Troubleshooting Commands

If something goes wrong, you can manually check:

```bash
# Check container logs
docker logs wander-postgres
docker logs wander-redis
docker logs wander-backend
docker logs wander-frontend

# Check container status
docker ps -a

# Check network
docker network ls
docker network inspect infrastructure_wander-network

# Check volumes
docker volume ls
docker volume inspect infrastructure_postgres_data

# Rebuild specific service
docker-compose up -d --build backend

# Restart specific service
docker-compose restart backend
```

