import { useState, useEffect } from 'react';
import axios from 'axios';

// Use relative URLs (proxied by Vite) or localhost for browser
// Vite proxy handles /api routes, so we use empty string for relative URLs
const API_URL = '';

interface ServiceProgress {
  name: string;
  status: 'pending' | 'installing' | 'starting' | 'healthy' | 'unhealthy' | 'error';
  progress: number;
  message: string;
}

interface Endpoint {
  url?: string;
  host?: string;
  port?: string;
  database?: string;
  user?: string;
  connectionString?: string;
  description: string;
  status: string;
}

interface SetupProgress {
  services: ServiceProgress[];
  overallProgress: number;
  allHealthy: boolean;
  endpoints?: {
    frontend: Endpoint;
    backend: Endpoint;
    database: Endpoint;
    redis: Endpoint;
    health: Endpoint;
    api: Endpoint;
    dashboard: Endpoint;
  };
  timestamp: string;
}

interface TestResults {
  configuration: { passed: number; total: number; status: string };
  services: { passed: number; total: number; status: string };
  integration: { passed: number; total: number; status: string };
}

interface Component {
  name: string;
  version: string;
  status: string;
  description: string;
  category: string;
  required?: boolean;
}

function SetupProgress() {
  const [progress, setProgress] = useState<SetupProgress | null>(null);
  const [testResults, setTestResults] = useState<TestResults | null>(null);
  const [components, setComponents] = useState<Component[]>([]);
  const [showResults, setShowResults] = useState(false);
  const [elapsedTime, setElapsedTime] = useState(0);

  useEffect(() => {
    const startTime = Date.now();
    const interval = setInterval(() => {
      setElapsedTime(Math.floor((Date.now() - startTime) / 1000));
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    // Fetch components list once
    const fetchComponents = async () => {
      try {
        const url = '/api/setup/components';
        const response = await axios.get<{ components: Component[] }>(url);
        setComponents(response.data.components);
      } catch (error) {
        console.error('Failed to fetch components:', error);
      }
    };

    fetchComponents();
  }, []);

  useEffect(() => {
    const fetchProgress = async () => {
      try {
        // Use relative URL - Vite proxy will forward to backend
        const url = '/api/setup/progress';
        const response = await axios.get<SetupProgress>(url);
        setProgress(response.data);

        // If all services are healthy, fetch test results
        if (response.data.allHealthy && !showResults) {
          setTimeout(async () => {
            try {
              // Use relative URL - Vite proxy will forward to backend
              const testUrl = '/api/setup/test-results';
              const testResponse = await axios.get<TestResults>(testUrl);
              setTestResults(testResponse.data);
              setShowResults(true);
            } catch (error) {
              console.error('Failed to fetch test results:', error);
            }
          }, 2000);
        }
      } catch (error) {
        console.error('Failed to fetch progress:', error);
      }
    };

    fetchProgress();
    const interval = setInterval(fetchProgress, 2000); // Poll every 2 seconds

    return () => clearInterval(interval);
  }, [showResults]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'healthy':
        return 'bg-green-500';
      case 'starting':
      case 'installing':
        return 'bg-blue-500';
      case 'unhealthy':
      case 'error':
        return 'bg-red-500';
      default:
        return 'bg-gray-300';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'healthy':
        return '✅';
      case 'starting':
        return '🔄';
      case 'installing':
        return '📦';
      case 'unhealthy':
      case 'error':
        return '❌';
      default:
        return '⏳';
    }
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  if (!progress) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-indigo-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading setup progress...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-12">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <div className="text-center mb-8">
            <h1 className="text-4xl font-bold text-gray-900 mb-2">
              🚀 Wander Developer Environment
            </h1>
            <p className="text-gray-600 text-lg">
              Development Environment Status & Package Information
            </p>
            <div className="mt-4 flex items-center justify-center gap-4 text-sm">
              <span className="text-gray-500">Elapsed time: {formatTime(elapsedTime)}</span>
              {progress && (
                <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                  progress.allHealthy 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-yellow-100 text-yellow-800'
                }`}>
                  {progress.allHealthy ? '✅ All Services Healthy' : '⏳ Services Starting...'}
                </span>
              )}
            </div>
          </div>

          {/* Overall Progress */}
          <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <div className="flex items-center justify-between mb-2">
              <h2 className="text-xl font-semibold text-gray-800">Overall Progress</h2>
              <span className="text-2xl font-bold text-indigo-600">{progress.overallProgress}%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-4 mb-4">
              <div
                className="bg-indigo-600 h-4 rounded-full transition-all duration-500"
                style={{ width: `${progress.overallProgress}%` }}
              ></div>
            </div>
            {progress.allHealthy && (
              <div className="text-center text-green-600 font-semibold animate-pulse">
                ✅ All services are ready!
              </div>
            )}
          </div>

          {/* Service Progress Bars */}
          <div className="space-y-4 mb-6">
            {progress.services.map((service, index) => (
              <div
                key={index}
                className="bg-white rounded-lg shadow-md p-6 border-l-4 border-indigo-500"
              >
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <span className="text-2xl">{getStatusIcon(service.status)}</span>
                    <h3 className="text-lg font-semibold text-gray-800">{service.name}</h3>
                  </div>
                  <span className="text-sm font-medium text-gray-600">{service.progress}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3 mb-2">
                  <div
                    className={`h-3 rounded-full transition-all duration-500 ${getStatusColor(service.status)}`}
                    style={{ width: `${service.progress}%` }}
                  ></div>
                </div>
                <p className="text-sm text-gray-600">{service.message}</p>
              </div>
            ))}
          </div>

          {/* Queue Status */}
          <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <h2 className="text-xl font-semibold text-gray-800 mb-4">Installation Queue</h2>
            <div className="space-y-2">
              {progress.services.map((service, index) => (
                <div
                  key={index}
                  className={`flex items-center gap-3 p-3 rounded ${
                    service.status === 'healthy'
                      ? 'bg-green-50 border border-green-200'
                      : service.status === 'starting' || service.status === 'installing'
                      ? 'bg-blue-50 border border-blue-200'
                      : 'bg-gray-50 border border-gray-200'
                  }`}
                >
                  <span className="text-xl">{getStatusIcon(service.status)}</span>
                  <div className="flex-1">
                    <div className="font-medium text-gray-800">{service.name}</div>
                    <div className="text-sm text-gray-600">{service.message}</div>
                  </div>
                  {service.status === 'healthy' && (
                    <span className="text-green-600 font-semibold">Complete</span>
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* Test Results */}
          {showResults && testResults && (
            <div className="bg-white rounded-lg shadow-lg p-6 animate-fade-in">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">📊 Test Results Summary</h2>
              
              <div className="space-y-4">
                {/* Configuration Tests */}
                <div className="border-l-4 border-green-500 bg-green-50 p-4 rounded">
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="font-semibold text-gray-800">Configuration Tests</h3>
                      <p className="text-sm text-gray-600">
                        {testResults.configuration.passed} / {testResults.configuration.total} passed
                      </p>
                    </div>
                    <span className="text-2xl">✅</span>
                  </div>
                </div>

                {/* Service Tests */}
                <div
                  className={`border-l-4 p-4 rounded ${
                    testResults.services.status === 'passed'
                      ? 'border-green-500 bg-green-50'
                      : testResults.services.status === 'partial'
                      ? 'border-yellow-500 bg-yellow-50'
                      : 'border-red-500 bg-red-50'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="font-semibold text-gray-800">Service Health Tests</h3>
                      <p className="text-sm text-gray-600">
                        {testResults.services.passed} / {testResults.services.total} services healthy
                      </p>
                    </div>
                    <span className="text-2xl">
                      {testResults.services.status === 'passed'
                        ? '✅'
                        : testResults.services.status === 'partial'
                        ? '⚠️'
                        : '❌'}
                    </span>
                  </div>
                </div>

                {/* Integration Tests */}
                <div
                  className={`border-l-4 p-4 rounded ${
                    testResults.integration.status === 'passed'
                      ? 'border-green-500 bg-green-50'
                      : testResults.integration.status === 'partial'
                      ? 'border-yellow-500 bg-yellow-50'
                      : 'border-gray-500 bg-gray-50'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="font-semibold text-gray-800">Integration Tests</h3>
                      <p className="text-sm text-gray-600">
                        {testResults.integration.passed} / {testResults.integration.total} connections verified
                      </p>
                    </div>
                    <span className="text-2xl">
                      {testResults.integration.status === 'passed'
                        ? '✅'
                        : testResults.integration.status === 'partial'
                        ? '⚠️'
                        : '⏳'}
                    </span>
                  </div>
                </div>
              </div>

              {/* Success Message */}
              {progress.allHealthy && (
                <div className="mt-6 p-4 bg-indigo-50 border border-indigo-200 rounded-lg">
                  <h3 className="font-semibold text-indigo-900 mb-2">🎉 Setup Complete!</h3>
                  <p className="text-sm text-indigo-700">
                    Your Wander development environment is ready. You can now start developing!
                  </p>
                  <div className="mt-4 flex gap-4 text-sm">
                    <a
                      href="/"
                      className="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 transition"
                    >
                      Go to Dashboard
                    </a>
                    <a
                      href="http://localhost:8080/dashboard"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="px-4 py-2 bg-white text-indigo-600 border border-indigo-600 rounded hover:bg-indigo-50 transition"
                    >
                      View API Dashboard
                    </a>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Connection Endpoints */}
          {progress.endpoints && (
            <div className="bg-white rounded-lg shadow-lg p-6 mt-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">🔌 Connection Endpoints</h2>
              
              <div className="space-y-4">
                {/* Frontend */}
                <div className="border-l-4 border-blue-500 bg-blue-50 p-4 rounded">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold text-gray-800">🌐 Frontend</h3>
                    <span className={`text-xs px-2 py-1 rounded font-semibold ${
                      progress.endpoints.frontend.status === 'ready' 
                        ? 'bg-green-100 text-green-700' 
                        : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {progress.endpoints.frontend.status === 'ready' ? 'Ready' : 'Starting'}
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-2">{progress.endpoints.frontend.description}</p>
                  <code className="text-sm bg-white px-3 py-2 rounded border border-blue-200 block">
                    {progress.endpoints.frontend.url}
                  </code>
                </div>

                {/* Backend API */}
                <div className="border-l-4 border-indigo-500 bg-indigo-50 p-4 rounded">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold text-gray-800">🔧 Backend API</h3>
                    <span className={`text-xs px-2 py-1 rounded font-semibold ${
                      progress.endpoints.backend.status === 'ready' 
                        ? 'bg-green-100 text-green-700' 
                        : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {progress.endpoints.backend.status === 'ready' ? 'Ready' : 'Starting'}
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-2">{progress.endpoints.backend.description}</p>
                  <code className="text-sm bg-white px-3 py-2 rounded border border-indigo-200 block">
                    {progress.endpoints.backend.url}
                  </code>
                </div>

                {/* Database */}
                <div className="border-l-4 border-purple-500 bg-purple-50 p-4 rounded">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold text-gray-800">🗄️ PostgreSQL Database</h3>
                    <span className={`text-xs px-2 py-1 rounded font-semibold ${
                      progress.endpoints.database.status === 'ready' 
                        ? 'bg-green-100 text-green-700' 
                        : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {progress.endpoints.database.status === 'ready' ? 'Ready' : 'Starting'}
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-2">{progress.endpoints.database.description}</p>
                  <div className="space-y-2">
                    <div>
                      <span className="text-xs text-gray-500">Connection String:</span>
                      <code className="text-sm bg-white px-3 py-2 rounded border border-purple-200 block mt-1 break-all">
                        {progress.endpoints.database.connectionString}
                      </code>
                    </div>
                    <div className="grid grid-cols-2 gap-2 text-xs">
                      <div>
                        <span className="text-gray-500">Host:</span>
                        <span className="ml-2 font-mono">{progress.endpoints.database.host}</span>
                      </div>
                      <div>
                        <span className="text-gray-500">Port:</span>
                        <span className="ml-2 font-mono">{progress.endpoints.database.port}</span>
                      </div>
                      <div>
                        <span className="text-gray-500">Database:</span>
                        <span className="ml-2 font-mono">{progress.endpoints.database.database}</span>
                      </div>
                      <div>
                        <span className="text-gray-500">User:</span>
                        <span className="ml-2 font-mono">{progress.endpoints.database.user}</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Redis */}
                <div className="border-l-4 border-red-500 bg-red-50 p-4 rounded">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold text-gray-800">⚡ Redis Cache</h3>
                    <span className={`text-xs px-2 py-1 rounded font-semibold ${
                      progress.endpoints.redis.status === 'ready' 
                        ? 'bg-green-100 text-green-700' 
                        : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {progress.endpoints.redis.status === 'ready' ? 'Ready' : 'Starting'}
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-2">{progress.endpoints.redis.description}</p>
                  <div className="space-y-2">
                    <div>
                      <span className="text-xs text-gray-500">Connection String:</span>
                      <code className="text-sm bg-white px-3 py-2 rounded border border-red-200 block mt-1">
                        {progress.endpoints.redis.connectionString}
                      </code>
                    </div>
                    <div className="grid grid-cols-2 gap-2 text-xs">
                      <div>
                        <span className="text-gray-500">Host:</span>
                        <span className="ml-2 font-mono">{progress.endpoints.redis.host}</span>
                      </div>
                      <div>
                        <span className="text-gray-500">Port:</span>
                        <span className="ml-2 font-mono">{progress.endpoints.redis.port}</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Additional Endpoints */}
                <div className="border-t border-gray-200 pt-4 mt-4">
                  <h3 className="font-semibold text-gray-800 mb-3">📋 Additional Endpoints</h3>
                  <div className="grid md:grid-cols-2 gap-3">
                    <div className="bg-gray-50 p-3 rounded border border-gray-200">
                      <div className="flex items-center justify-between mb-1">
                        <span className="text-sm font-medium text-gray-700">Health Check</span>
                        <span className={`text-xs px-2 py-0.5 rounded ${
                          progress.endpoints.health.status === 'ready' 
                            ? 'bg-green-100 text-green-700' 
                            : 'bg-yellow-100 text-yellow-700'
                        }`}>
                          {progress.endpoints.health.status === 'ready' ? '✓' : '⏳'}
                        </span>
                      </div>
                      <code className="text-xs bg-white px-2 py-1 rounded block">
                        {progress.endpoints.health.url}
                      </code>
                    </div>
                    <div className="bg-gray-50 p-3 rounded border border-gray-200">
                      <div className="flex items-center justify-between mb-1">
                        <span className="text-sm font-medium text-gray-700">API Base</span>
                        <span className={`text-xs px-2 py-0.5 rounded ${
                          progress.endpoints.api.status === 'ready' 
                            ? 'bg-green-100 text-green-700' 
                            : 'bg-yellow-100 text-yellow-700'
                        }`}>
                          {progress.endpoints.api.status === 'ready' ? '✓' : '⏳'}
                        </span>
                      </div>
                      <code className="text-xs bg-white px-2 py-1 rounded block">
                        {progress.endpoints.api.url}
                      </code>
                    </div>
                    <div className="bg-gray-50 p-3 rounded border border-gray-200">
                      <div className="flex items-center justify-between mb-1">
                        <span className="text-sm font-medium text-gray-700">Dashboard</span>
                        <span className={`text-xs px-2 py-0.5 rounded ${
                          progress.endpoints.dashboard.status === 'ready' 
                            ? 'bg-green-100 text-green-700' 
                            : 'bg-yellow-100 text-yellow-700'
                        }`}>
                          {progress.endpoints.dashboard.status === 'ready' ? '✓' : '⏳'}
                        </span>
                      </div>
                      <code className="text-xs bg-white px-2 py-1 rounded block">
                        {progress.endpoints.dashboard.url}
                      </code>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Installed Components List - Show prominently */}
          {components.length > 0 && (
            <div className="bg-white rounded-lg shadow-lg p-6 mt-6 animate-fade-in">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-gray-900">📦 Installed Packages & Versions</h2>
                <div className="text-right">
                  <p className="text-3xl font-bold text-indigo-600">{components.length}</p>
                  <p className="text-xs text-gray-500">packages installed</p>
                </div>
              </div>
              
              {/* Group by category */}
              {['Runtime', 'Database', 'Cache', 'Backend', 'Frontend', 'Build Tool', 'Language', 'Infrastructure', 'Development'].map((category) => {
                const categoryComponents = components.filter(c => c.category === category);
                if (categoryComponents.length === 0) return null;

                return (
                  <div key={category} className="mb-6 last:mb-0">
                    <h3 className="text-lg font-semibold text-gray-700 mb-3 border-b border-gray-200 pb-2">
                      {category}
                    </h3>
                    <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-3">
                      {categoryComponents.map((component, index) => (
                        <div
                          key={index}
                          className="flex items-start gap-3 p-4 bg-gray-50 rounded-lg border-2 border-gray-200 hover:border-indigo-400 hover:bg-indigo-50 transition-all"
                        >
                          <div className="flex-shrink-0 mt-1">
                            <div className={`w-3 h-3 rounded-full ${component.required ? 'bg-green-500' : 'bg-blue-400'}`}></div>
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center justify-between mb-2">
                              <div className="flex items-center gap-2">
                                <h4 className="font-bold text-gray-900 text-base">
                                  {component.name}
                                </h4>
                                {component.required && (
                                  <span className="text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded font-semibold">
                                    Required
                                  </span>
                                )}
                              </div>
                            </div>
                            <div className="mb-2">
                              <span className="text-sm font-mono font-semibold text-indigo-600 bg-indigo-50 px-2 py-1 rounded">
                                v{component.version}
                              </span>
                            </div>
                            <p className="text-xs text-gray-600">
                              {component.description}
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                );
              })}

              {/* Summary & Status */}
              <div className="mt-6 pt-6 border-t-2 border-gray-300">
                <div className="grid md:grid-cols-3 gap-4">
                  <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-2xl">✅</span>
                      <h3 className="font-semibold text-green-900">Required Packages</h3>
                    </div>
                    <p className="text-2xl font-bold text-green-700">
                      {components.filter(c => c.required).length}
                    </p>
                    <p className="text-xs text-green-600 mt-1">All installed</p>
                  </div>
                  
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-2xl">📦</span>
                      <h3 className="font-semibold text-blue-900">Total Packages</h3>
                    </div>
                    <p className="text-2xl font-bold text-blue-700">
                      {components.length}
                    </p>
                    <p className="text-xs text-blue-600 mt-1">Ready for development</p>
                  </div>
                  
                  <div className="bg-indigo-50 border border-indigo-200 rounded-lg p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-2xl">🚀</span>
                      <h3 className="font-semibold text-indigo-900">Environment Status</h3>
                    </div>
                    <p className={`text-lg font-bold ${progress?.allHealthy ? 'text-green-700' : 'text-yellow-700'}`}>
                      {progress?.allHealthy ? 'Ready' : 'Starting...'}
                    </p>
                    <p className="text-xs text-indigo-600 mt-1">
                      {progress?.overallProgress || 0}% complete
                    </p>
                  </div>
                </div>
                
                {/* What's Needed Section */}
                <div className="mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                  <h3 className="font-semibold text-yellow-900 mb-2 flex items-center gap-2">
                    <span>💡</span>
                    What You Need to Know
                  </h3>
                  <ul className="text-sm text-yellow-800 space-y-1 list-disc list-inside">
                    <li>All required packages are installed and ready</li>
                    <li>Development tools (ESLint, Prettier) are configured</li>
                    <li>Hot reload is enabled - edit files and see changes instantly</li>
                    <li>All services are containerized and isolated</li>
                    <li>Database migrations run automatically on startup</li>
                  </ul>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default SetupProgress;

