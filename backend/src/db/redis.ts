import { createClient } from 'redis';
import dotenv from 'dotenv';

dotenv.config();

export const redisClient = createClient({
  url: `redis://${process.env.REDIS_HOST || 'redis'}:${process.env.REDIS_PORT || '6379'}`,
});

redisClient.on('error', (err) => {
  console.error('\x1b[31m[✗]\x1b[0m Redis client error:', err);
});

redisClient.on('connect', () => {
  // Connection logged in main index.ts
});

