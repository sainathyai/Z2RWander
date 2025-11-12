# Architecture Documentation

## System Overview

The Wander Developer Environment is a containerized multi-service application designed for rapid local development setup.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Developer Machine                         │
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │   Frontend   │────────▶│   Backend    │                 │
│  │  (React)     │  HTTP   │  (Node.js)   │                 │
│  │  Port: 3000  │         │  Port: 8080  │                 │
│  └──────────────┘         └──────┬───────┘                 │
│                                   │                          │
│                          ┌────────┴────────┐                │
│                          │                 │                │
│                   ┌──────▼──────┐  ┌──────▼──────┐         │
│                   │ PostgreSQL  │  │    Redis    │         │
│                   │  Port: 5432 │  │  Port: 6379 │         │
│                   └─────────────┘  └─────────────┘         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Service Interaction

### Frontend → Backend
- **Protocol:** HTTP/REST
- **Port:** 3000 → 8080
- **Communication:** API calls via Axios
- **Proxy:** Vite dev server proxies `/api` and `/health` to backend

### Backend → PostgreSQL
- **Protocol:** PostgreSQL wire protocol
- **Port:** 5432
- **Client:** `pg` (node-postgres)
- **Connection:** Connection pool managed by `pg.Pool`

### Backend → Redis
- **Protocol:** Redis protocol
- **Port:** 6379
- **Client:** `redis` (node-redis v4)
- **Connection:** Single connection with auto-reconnect

## Network Topology

All services run in a Docker bridge network (`wander-network`):

- **Network Type:** Bridge
- **Network Name:** `wander-network`
- **Service Discovery:** Docker Compose DNS
  - `postgres` → PostgreSQL container
  - `redis` → Redis container
  - `backend` → Backend API container
  - `frontend` → Frontend container

## Data Flow

### Request Flow (Frontend → Backend → Database)

```
User Browser
    │
    ▼
Frontend (React)
    │ HTTP Request
    ▼
Vite Dev Server (Proxy)
    │
    ▼
Backend API (Express)
    │
    ├─▶ PostgreSQL (Read/Write)
    │
    └─▶ Redis (Cache)
    │
    ▼
Response (JSON)
    │
    ▼
Frontend (React)
    │
    ▼
User Browser
```

### Database Schema

```
wander_dev
├── users
│   ├── id (UUID, Primary Key)
│   ├── email (String, Unique)
│   ├── name (String)
│   └── created_at (Timestamp)
└── sample_data
    ├── id (Serial, Primary Key)
    ├── title (String)
    ├── content (Text)
    └── created_at (Timestamp)
```

## Container Architecture

### Frontend Container
- **Base Image:** `node:20-alpine`
- **Build Tool:** Vite
- **Framework:** React 18
- **Styling:** Tailwind CSS
- **Volume Mounts:**
  - `./frontend:/app` (source code)
  - `/app/node_modules` (excluded from mount)

### Backend Container
- **Base Image:** `node:20-alpine`
- **Runtime:** Node.js 20
- **Framework:** Express
- **Language:** TypeScript
- **Volume Mounts:**
  - `./backend:/app` (source code)
  - `/app/node_modules` (excluded from mount)

### PostgreSQL Container
- **Base Image:** `postgres:15-alpine`
- **Version:** PostgreSQL 15
- **Volume Mounts:**
  - `postgres_data:/var/lib/postgresql/data` (persistent data)
  - `./backend/migrations:/docker-entrypoint-initdb.d` (init scripts)

### Redis Container
- **Base Image:** `redis:7-alpine`
- **Version:** Redis 7
- **Volume Mounts:**
  - `redis_data:/data` (persistent data)

## Environment Variables

### Frontend
- `VITE_API_URL` - Backend API URL (default: `http://backend:8080`)

### Backend
- `NODE_ENV` - Environment (development/production)
- `POSTGRES_HOST` - Database host (default: `postgres`)
- `POSTGRES_PORT` - Database port (default: `5432`)
- `POSTGRES_USER` - Database user (default: `wander`)
- `POSTGRES_PASSWORD` - Database password
- `POSTGRES_DB` - Database name (default: `wander_dev`)
- `REDIS_HOST` - Redis host (default: `redis`)
- `REDIS_PORT` - Redis port (default: `6379`)
- `API_PORT` - API server port (default: `8080`)
- `API_HOST` - API server host (default: `0.0.0.0`)

## Health Checks

All services implement health checks:

- **PostgreSQL:** `pg_isready -U wander`
- **Redis:** `redis-cli ping`
- **Backend:** `GET /health`
- **Frontend:** Vite dev server health

## Security Considerations

### Development Environment
- Default passwords are used (change for production)
- No SSL/TLS (HTTPS) by default
- CORS enabled for all origins
- Database exposed on localhost

### Production Recommendations
- Use strong, unique passwords
- Enable SSL/TLS
- Restrict CORS origins
- Use secrets management
- Enable database encryption
- Implement rate limiting
- Add authentication/authorization

## Performance Characteristics

### Startup Times
- **First Run:** ~5-10 minutes (image downloads)
- **Subsequent Runs:** ~30-60 seconds
- **Rebuild After Code Change:** ~10-30 seconds

### Resource Usage
- **Memory:** ~1-2 GB total
- **CPU:** Low (idle), Medium (active development)
- **Disk:** ~2-3 GB (images + volumes)

## Scalability

The current architecture is designed for local development. For production:

- Use Kubernetes for orchestration
- Implement horizontal scaling
- Add load balancers
- Use managed database services
- Implement caching layers
- Add monitoring and logging

