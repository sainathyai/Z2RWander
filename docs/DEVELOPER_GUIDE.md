# Developer Guide

This guide helps you extend and modify the Wander Developer Environment.

## Adding a New Service

### 1. Create Service Directory

```bash
mkdir -p services/new-service
cd services/new-service
```

### 2. Create Dockerfile

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "start"]
```

### 3. Add to docker-compose.yml

```yaml
services:
  new-service:
    build:
      context: ../services/new-service
      dockerfile: Dockerfile
    container_name: wander-new-service
    ports:
      - "9000:9000"
    environment:
      - NODE_ENV=development
    networks:
      - wander-network
    volumes:
      - ../services/new-service:/app
      - /app/node_modules
```

### 4. Update Makefile

Add commands for your service:

```makefile
restart-new-service:
	@cd infrastructure && docker-compose restart new-service
```

## Modifying Existing Services

### Backend Changes

1. **Add a new route:**
   ```typescript
   // backend/src/routes/my-route.ts
   import express from 'express';
   export const myRouter = express.Router();
   myRouter.get('/', (req, res) => {
     res.json({ message: 'Hello' });
   });
   ```

2. **Register the route:**
   ```typescript
   // backend/src/index.ts
   import { myRouter } from './routes/my-route.js';
   app.use('/my-route', myRouter);
   ```

3. **Restart the service:**
   ```bash
   make restart-api
   ```

### Frontend Changes

1. **Add a new component:**
   ```typescript
   // frontend/src/components/MyComponent.tsx
   export const MyComponent = () => {
     return <div>Hello</div>;
   };
   ```

2. **Use the component:**
   ```typescript
   // frontend/src/App.tsx
   import { MyComponent } from './components/MyComponent';
   ```

3. **Hot reload will pick up changes automatically!**

## Database Schema Changes

### 1. Create a Migration

```bash
make migration NAME=add_user_roles
```

This creates: `backend/migrations/YYYYMMDDHHMMSS_add_user_roles.sql`

### 2. Write Migration SQL

```sql
-- Migration: add_user_roles
-- Created: 2024-01-01

ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'user';
CREATE INDEX idx_users_role ON users(role);
```

### 3. Apply Migration

```bash
make db-migrate
```

Or manually:

```bash
make shell-db
# Then in psql:
\i /docker-entrypoint-initdb.d/YYYYMMDDHHMMSS_add_user_roles.sql
```

### 4. Update Seed Data (if needed)

Edit `backend/seeds/001_sample_users.sql` to include new fields.

## API Endpoint Development

### Creating a New Endpoint

1. **Create route file:**
   ```typescript
   // backend/src/routes/users.ts
   import express from 'express';
   import { dbClient } from '../db/client.js';
   
   export const usersRouter = express.Router();
   
   usersRouter.get('/', async (req, res) => {
     try {
       const result = await dbClient.query('SELECT * FROM users');
       res.json(result.rows);
     } catch (error) {
       res.status(500).json({ error: 'Database error' });
     }
   });
   ```

2. **Register route:**
   ```typescript
   // backend/src/index.ts
   import { usersRouter } from './routes/users.js';
   app.use('/api/users', usersRouter);
   ```

3. **Test the endpoint:**
   ```bash
   curl http://localhost:8080/api/users
   ```

### Error Handling

Always wrap database operations in try-catch:

```typescript
try {
  const result = await dbClient.query('...');
  res.json(result.rows);
} catch (error) {
  console.error('Error:', error);
  res.status(500).json({ 
    error: 'Internal server error',
    message: error instanceof Error ? error.message : 'Unknown error'
  });
}
```

## Environment Variables

### Adding New Variables

1. **Backend:**
   ```typescript
   // backend/src/index.ts
   const MY_NEW_VAR = process.env.MY_NEW_VAR || 'default';
   ```

2. **Frontend:**
   ```typescript
   // frontend/src/App.tsx
   const MY_NEW_VAR = import.meta.env.VITE_MY_NEW_VAR;
   ```

3. **Docker Compose:**
   ```yaml
   services:
     backend:
       environment:
         - MY_NEW_VAR=${MY_NEW_VAR:-default}
   ```

4. **Create `.env` file:**
   ```env
   MY_NEW_VAR=my_value
   ```

## Testing

### Running Tests

```bash
make test              # All tests
make test-api          # Backend tests
make test-frontend     # Frontend tests
```

### Writing Tests

**Backend test example:**
```typescript
// backend/src/routes/__tests__/users.test.ts
import { describe, it, expect } from 'vitest';

describe('Users API', () => {
  it('should return users', async () => {
    // Test implementation
  });
});
```

## Debugging

### View Logs

```bash
make logs              # All services
make logs api          # Backend only
make logs frontend     # Frontend only
```

### Shell Access

```bash
make shell-api         # Backend container
make shell-db          # PostgreSQL console
make shell-redis       # Redis CLI
```

### Database Debugging

```bash
# Connect to database
make shell-db

# Run queries
SELECT * FROM users;
\d users  # Describe table
\dt       # List tables
```

## Code Quality

### Linting

```bash
make lint              # Check for issues
make lint-fix          # Auto-fix issues
```

### Formatting

```bash
make format            # Format all code
```

### Pre-commit Hooks

Husky automatically runs linting and formatting before commits. To bypass:

```bash
git commit --no-verify -m "message"
```

## Best Practices

1. **Always use TypeScript** - Type safety prevents bugs
2. **Follow existing patterns** - Consistency is key
3. **Write migrations** - Never modify schema directly
4. **Test locally first** - Verify before committing
5. **Use meaningful names** - Clear code is maintainable
6. **Document complex logic** - Help future developers
7. **Keep commits atomic** - One logical change per commit
8. **Update documentation** - Keep docs in sync with code

## Common Tasks

### Reset Everything

```bash
make clean
make dev
make seed
```

### Update Dependencies

```bash
cd backend && npm update
cd ../frontend && npm update
make rebuild
```

### Change Ports

Edit `.env`:
```env
API_PORT=8081
VITE_PORT=3001
```

Then restart:
```bash
make down
make dev
```

## Getting Help

- Check [Troubleshooting Guide](TROUBLESHOOTING.md)
- Review [FAQ](FAQ.md)
- Open an issue on GitHub

