import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

export const dbClient = new Pool({
  host: process.env.POSTGRES_HOST || 'postgres',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  user: process.env.POSTGRES_USER || 'wander',
  password: process.env.POSTGRES_PASSWORD || 'dev_password_123',
  database: process.env.POSTGRES_DB || 'wander_dev',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test connection
dbClient.on('connect', () => {
  // Connection logged in main index.ts
});

dbClient.on('error', (err) => {
  console.error('\x1b[31m[✗]\x1b[0m PostgreSQL client error:', err);
});

