import { useState, useEffect } from 'react'
import axios from 'axios'
import SetupProgress from './SetupProgress'

// Use relative URLs (proxied by Vite) - Vite proxy handles /api routes
const API_URL = ''

function App() {
  // Always show the developer-focused setup progress page
  // This provides comprehensive environment status, packages, and what's needed
  return <SetupProgress />
}

export default App
