import express from 'express';
import { dbClient } from '../db/client.js';
import { redisClient } from '../db/redis.js';

export const apiRouter = express.Router();

// Service status endpoint
apiRouter.get('/status', async (req, res) => {
  const services = [
    {
      name: 'Backend API',
      status: 'healthy' as const,
      message: 'API is running',
    },
    {
      name: 'Database',
      status: 'checking' as const,
    },
    {
      name: 'Redis Cache',
      status: 'checking' as const,
    },
  ];

  // Check database
  try {
    await dbClient.query('SELECT 1');
    services[1].status = 'healthy';
    services[1].message = 'Connected to PostgreSQL';
  } catch (error) {
    services[1].status = 'unhealthy';
    services[1].message = 'Cannot connect to database';
  }

  // Check Redis
  try {
    await redisClient.ping();
    services[2].status = 'healthy';
    services[2].message = 'Connected to Redis';
  } catch (error) {
    services[2].status = 'unhealthy';
    services[2].message = 'Cannot connect to Redis';
  }

  res.json({ services });
});

// Database test endpoint
apiRouter.get('/db-test', async (req, res) => {
  try {
    const result = await dbClient.query('SELECT NOW() as current_time, version() as pg_version');
    res.json({
      success: true,
      message: 'Database connection successful',
      data: result.rows[0],
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Database connection failed',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

// Redis test endpoint
apiRouter.get('/cache-test', async (req, res) => {
  try {
    const testKey = 'test:connection';
    const testValue = new Date().toISOString();
    
    await redisClient.set(testKey, testValue, { EX: 10 });
    const retrieved = await redisClient.get(testKey);
    
    res.json({
      success: true,
      message: 'Redis connection successful',
      data: {
        set: testValue,
        retrieved,
        match: testValue === retrieved,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Redis connection failed',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

// Sample data endpoint
apiRouter.post('/data', async (req, res) => {
  try {
    const { key, value } = req.body;
    
    if (!key || !value) {
      return res.status(400).json({
        success: false,
        message: 'Key and value are required',
      });
    }

    // Store in Redis
    await redisClient.set(`data:${key}`, JSON.stringify(value), { EX: 3600 });
    
    // Optionally store in database
    // await dbClient.query('INSERT INTO data (key, value) VALUES ($1, $2)', [key, JSON.stringify(value)]);

    res.json({
      success: true,
      message: 'Data stored successfully',
      data: { key, value },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to store data',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

apiRouter.get('/data/:key', async (req, res) => {
  try {
    const { key } = req.params;
    const value = await redisClient.get(`data:${key}`);
    
    if (!value) {
      return res.status(404).json({
        success: false,
        message: 'Key not found',
      });
    }

    res.json({
      success: true,
      data: {
        key,
        value: JSON.parse(value),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve data',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

