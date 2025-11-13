#!/usr/bin/env node
/**
 * Simple Dashboard Backend - Runs directly on host (no container)
 * Provides API endpoints for monitoring Docker containers
 * Uses only Node.js built-in modules - no dependencies required
 */

const { exec } = require('child_process');
const { promisify } = require('util');
const http = require('http');
const url = require('url');

const execAsync = promisify(exec);
const PORT = process.env.DASHBOARD_PORT || 8081;
const HOST = process.env.DASHBOARD_HOST || 'localhost';

// Check Docker container status
async function checkContainerStatus(containerName) {
  try {
    const { stdout } = await execAsync(`docker ps -a --filter "name=${containerName}" --format "{{.Status}}"`);
    if (stdout.includes('Up')) {
      return 'running';
    } else if (stdout.trim()) {
      return 'stopped';
    }
    return 'not-found';
  } catch {
    return 'not-found';
  }
}

// Check HTTP endpoint
function checkHttpEndpoint(urlString) {
  return new Promise((resolve) => {
    try {
      const urlObj = new URL(urlString);
      const options = {
        hostname: urlObj.hostname,
        port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
        path: urlObj.pathname || '/',
        method: 'GET',
        timeout: 3000,
      };

      const req = http.request(options, (res) => {
        resolve(res.statusCode !== undefined);
      });

      req.on('error', () => resolve(false));
      req.on('timeout', () => {
        req.destroy();
        resolve(false);
      });

      req.end();
    } catch {
      resolve(false);
    }
  });
}

// HTTP server
const server = http.createServer(async (req, res) => {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Content-Type', 'application/json');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  if (pathname === '/api/setup/progress') {
    try {
      const services = [
        {
          name: 'PostgreSQL Database',
          status: 'pending',
          progress: 0,
          message: 'Checking...',
          containerName: 'wander-postgres',
        },
        {
          name: 'Redis Cache',
          status: 'pending',
          progress: 0,
          message: 'Checking...',
          containerName: 'wander-redis',
        },
        {
          name: 'Backend API',
          status: 'pending',
          progress: 0,
          message: 'Checking...',
          containerName: 'wander-backend',
        },
        {
          name: 'Frontend',
          status: 'pending',
          progress: 0,
          message: 'Checking...',
          containerName: 'wander-frontend',
        },
      ];

      // Check each service
      for (const service of services) {
        if (!service.containerName) continue;

        const containerStatus = await checkContainerStatus(service.containerName);

        if (containerStatus === 'not-found') {
          service.status = 'error';
          service.progress = 0;
          service.message = 'Container not found (may have been removed)';
        } else if (containerStatus === 'stopped') {
          service.status = 'unhealthy';
          service.progress = 0;
          service.message = 'Container stopped';
        } else {
          // Container is running, check health
          if (service.containerName === 'wander-postgres') {
            // For PostgreSQL, try to connect via psql or check port
            try {
              const { stdout } = await execAsync('docker exec wander-postgres pg_isready -U wander 2>&1 || echo "not ready"');
              const isHealthy = stdout.includes('accepting connections');
              service.status = isHealthy ? 'healthy' : 'starting';
              service.progress = isHealthy ? 100 : 50;
              service.message = isHealthy ? 'Database running' : 'Database starting...';
            } catch {
              service.status = 'starting';
              service.progress = 50;
              service.message = 'Database starting...';
            }
          } else if (service.containerName === 'wander-redis') {
            // For Redis, try to ping
            try {
              const { stdout } = await execAsync('docker exec wander-redis redis-cli ping 2>&1 || echo "not ready"');
              const isHealthy = stdout.includes('PONG');
              service.status = isHealthy ? 'healthy' : 'starting';
              service.progress = isHealthy ? 100 : 50;
              service.message = isHealthy ? 'Redis running' : 'Redis starting...';
            } catch {
              service.status = 'starting';
              service.progress = 50;
              service.message = 'Redis starting...';
            }
          } else if (service.containerName === 'wander-backend') {
            const isHealthy = await checkHttpEndpoint('http://localhost:8080/health');
            service.status = isHealthy ? 'healthy' : 'starting';
            service.progress = isHealthy ? 100 : 70;
            service.message = isHealthy ? 'API is responding' : 'Backend starting up...';
          } else if (service.containerName === 'wander-frontend') {
            const isHealthy = await checkHttpEndpoint('http://localhost:3000');
            service.status = isHealthy ? 'healthy' : 'starting';
            service.progress = isHealthy ? 100 : 85;
            service.message = isHealthy ? 'Frontend is accessible' : 'Frontend starting up...';
          }
        }
      }

      const overallProgress = services.reduce((sum, s) => sum + s.progress, 0) / services.length;
      const allHealthy = services.every(s => s.status === 'healthy');

      const result = {
        services,
        overallProgress: Math.round(overallProgress),
        allHealthy,
        endpoints: {
          frontend: {
            url: 'http://localhost:3000',
            description: 'Frontend application',
            status: services.find(s => s.containerName === 'wander-frontend')?.status === 'healthy' ? 'ready' : 'starting',
          },
          backend: {
            url: 'http://localhost:8080',
            description: 'Backend API',
            status: services.find(s => s.containerName === 'wander-backend')?.status === 'healthy' ? 'ready' : 'starting',
          },
          database: {
            host: 'localhost',
            port: '5432',
            database: 'wander_dev',
            user: 'wander',
            connectionString: 'postgresql://wander:dev_password_123@localhost:5432/wander_dev',
            description: 'PostgreSQL database',
            status: services.find(s => s.containerName === 'wander-postgres')?.status === 'healthy' ? 'ready' : 'starting',
          },
          redis: {
            host: 'localhost',
            port: '6379',
            connectionString: 'redis://localhost:6379',
            description: 'Redis cache',
            status: services.find(s => s.containerName === 'wander-redis')?.status === 'healthy' ? 'ready' : 'starting',
          },
          health: {
            url: 'http://localhost:8080/health',
            description: 'Health check endpoint',
            status: services.find(s => s.containerName === 'wander-backend')?.status === 'healthy' ? 'ready' : 'starting',
          },
          api: {
            url: 'http://localhost:8080/api',
            description: 'API base endpoint',
            status: services.find(s => s.containerName === 'wander-backend')?.status === 'healthy' ? 'ready' : 'starting',
          },
          dashboard: {
            url: 'http://localhost:8080/dashboard',
            description: 'API dashboard',
            status: services.find(s => s.containerName === 'wander-backend')?.status === 'healthy' ? 'ready' : 'starting',
          },
        },
        timestamp: new Date().toISOString(),
      };

      res.writeHead(200);
      res.end(JSON.stringify(result));
    } catch (error) {
      console.error('Error in /progress endpoint:', error);
      const errorResult = {
        error: 'Failed to fetch progress',
        message: error.message,
        services: [],
        overallProgress: 0,
        allHealthy: false,
        endpoints: {},
        timestamp: new Date().toISOString(),
      };
      res.writeHead(500);
      res.end(JSON.stringify(errorResult));
    }
    return;
  }

  if (pathname === '/api/setup/components') {
    try {
      const components = [
        { name: 'Node.js', version: process.version, status: 'installed', description: 'JavaScript runtime', category: 'Runtime', required: true },
        { name: 'Docker', version: 'unknown', status: 'installed', description: 'Container platform', category: 'Infrastructure', required: true },
        { name: 'PostgreSQL', version: '15', status: 'installed', description: 'Database', category: 'Database', required: true },
        { name: 'Redis', version: '7', status: 'installed', description: 'Cache', category: 'Cache', required: true },
      ];

      // Try to get Docker version
      try {
        const { stdout } = await execAsync('docker --version');
        const dockerVersion = stdout.match(/version\s+([\d.]+)/)?.[1] || 'unknown';
        const comp = components.find(c => c.name === 'Docker');
        if (comp) comp.version = dockerVersion;
      } catch {}

      res.writeHead(200);
      res.end(JSON.stringify({ components }));
    } catch (error) {
      console.error('Error in /components endpoint:', error);
      const errorResult = {
        error: 'Failed to fetch components',
        message: error.message,
        components: [],
      };
      res.writeHead(500);
      res.end(JSON.stringify(errorResult));
    }
    return;
  }

  if (pathname === '/health') {
    res.writeHead(200);
    res.end(JSON.stringify({ status: 'ok', service: 'dashboard-backend' }));
    return;
  }

  // 404
  res.writeHead(404);
  res.end(JSON.stringify({ error: 'Not found' }));
});

server.listen(PORT, HOST, () => {
  console.log(`Dashboard Backend running on http://${HOST}:${PORT}`);
});
