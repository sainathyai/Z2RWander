import express from 'express';
import { dbClient } from '../db/client.js';
import { redisClient } from '../db/redis.js';

export const dashboardRouter = express.Router();

// Simple dashboard endpoint
dashboardRouter.get('/', async (req, res) => {
  const services = {
    api: { status: 'healthy', uptime: process.uptime() },
    database: { status: 'checking' as const },
    redis: { status: 'checking' as const },
  };

  // Check database
  try {
    const dbResult = await dbClient.query('SELECT NOW() as time, version() as version');
    services.database = {
      status: 'healthy',
      version: dbResult.rows[0].version.split(' ')[0] + ' ' + dbResult.rows[0].version.split(' ')[1],
      time: dbResult.rows[0].time,
    };
  } catch (error) {
    services.database = {
      status: 'unhealthy',
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }

  // Check Redis
  try {
    await redisClient.ping();
    const info = await redisClient.info('server');
    services.redis = {
      status: 'healthy',
      version: info.split('\n').find((line: string) => line.startsWith('redis_version:'))?.split(':')[1]?.trim() || 'unknown',
    };
  } catch (error) {
    services.redis = {
      status: 'unhealthy',
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }

  res.json({
    timestamp: new Date().toISOString(),
    services,
    system: {
      nodeVersion: process.version,
      platform: process.platform,
      memory: {
        used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
        total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
        unit: 'MB',
      },
    },
  });
});

