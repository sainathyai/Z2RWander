import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { healthRouter } from './routes/health.js';
import { apiRouter } from './routes/api.js';
import { dashboardRouter } from './routes/dashboard.js';
import { setupRouter } from './routes/setup.js';
import { dbClient } from './db/client.js';
import { redisClient } from './db/redis.js';

dotenv.config();

const app = express();
const PORT = process.env.API_PORT || 8080;
const HOST = process.env.API_HOST || '0.0.0.0';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/health', healthRouter);
app.use('/api', apiRouter);
app.use('/dashboard', dashboardRouter);
app.use('/api/setup', setupRouter);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Wander Developer Environment API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      api: '/api',
      dashboard: '/dashboard',
    },
  });
});

// Error handling middleware
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong',
  });
});

// Helper function for colored console output
const log = {
  info: (msg: string) => console.log(`\x1b[34m[INFO]\x1b[0m ${msg}`),
  success: (msg: string) => console.log(`\x1b[32m[✓]\x1b[0m ${msg}`),
  error: (msg: string) => console.error(`\x1b[31m[✗]\x1b[0m ${msg}`),
  warn: (msg: string) => console.warn(`\x1b[33m[!]\x1b[0m ${msg}`),
};

// Start server
const startServer = async () => {
  try {
    log.info('Initializing Wander Developer Environment API...');
    
    // Initialize database connection
    log.info('Connecting to PostgreSQL...');
    await dbClient.connect();
    log.success('Connected to PostgreSQL');

    // Initialize Redis connection
    log.info('Connecting to Redis...');
    await redisClient.connect();
    log.success('Connected to Redis');

    app.listen(PORT, HOST, () => {
      console.log('');
      console.log('\x1b[32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\x1b[0m');
      console.log('\x1b[32m  ✅ Wander Developer Environment API Started Successfully\x1b[0m');
      console.log('\x1b[32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\x1b[0m');
      console.log('');
      log.success(`Server running on http://${HOST}:${PORT}`);
      log.success(`Health check: http://${HOST}:${PORT}/health`);
      log.success(`API endpoints: http://${HOST}:${PORT}/api`);
      console.log('');
    });
  } catch (error) {
    log.error(`Failed to start server: ${error instanceof Error ? error.message : 'Unknown error'}`);
    if (error instanceof Error && error.stack) {
      console.error(error.stack);
    }
    process.exit(1);
  }
};

// Graceful shutdown
const shutdown = async (signal: string) => {
  log.warn(`${signal} received, shutting down gracefully...`);
  try {
    await dbClient.end();
    log.success('PostgreSQL connection closed');
    await redisClient.quit();
    log.success('Redis connection closed');
    log.success('Shutdown complete');
    process.exit(0);
  } catch (error) {
    log.error(`Error during shutdown: ${error instanceof Error ? error.message : 'Unknown error'}`);
    process.exit(1);
  }
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

startServer();

