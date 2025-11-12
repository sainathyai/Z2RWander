# Windows Setup Guide for Junior Developers

This guide will walk you through setting up your new Windows machine to run the Wander Developer Environment.

## Prerequisites Checklist

Before you start, you'll need:
- [ ] Windows 10 or 11
- [ ] Administrator access
- [ ] Internet connection
- [ ] At least 8GB RAM (16GB recommended)
- [ ] At least 20GB free disk space

---

## Step 0: Automated Installation (Optional)

**Quick Setup:** We provide automated installation scripts that can install all prerequisites for you.

### Option A: PowerShell Script (Recommended for Windows)

1. **Open PowerShell as Administrator:**
   - Right-click on PowerShell
   - Select "Run as Administrator"

2. **Run the installation script:**
   ```powershell
   cd "C:\Users\Sainatha Yatham\Documents\GauntletAI\Week5\Z2RWander"
   .\scripts\install-prerequisites.ps1
   ```

   This script will automatically:
   - Install Chocolatey (if not already installed)
   - Install Git
   - Install Docker Desktop
   - Install Make (optional)
   - Verify all installations

### Option B: Bash Script (For Git Bash or WSL)

1. **Open Git Bash or WSL**

2. **Run the installation script:**
   ```bash
   cd /c/Users/Sainatha\ Yatham/Documents/GauntletAI/Week5/Z2RWander
   chmod +x scripts/install-prerequisites.sh
   ./scripts/install-prerequisites.sh
   ```

   This script will automatically:
   - Detect your Linux distribution
   - Install Git using the appropriate package manager
   - Install Docker Engine
   - Install Docker Compose
   - Install Make
   - Verify all installations

**Note:** If you prefer manual installation or the scripts don't work on your system, follow the manual steps below.

---

## Step 1: Install Git

Git is required to clone the repository and manage version control.

### Installation Steps:

1. **Download Git for Windows:**
   - Visit: https://git-scm.com/download/win
   - Download the latest version (64-bit installer)

2. **Run the Installer:**
   - Double-click the downloaded `.exe` file
   - Click "Next" through the installation wizard
   - **Important:** Keep default options, but make sure:
     - ✅ "Git from the command line and also from 3rd-party software" is selected
     - ✅ "Use bundled OpenSSH" is selected
     - ✅ "Use the OpenSSL library" is selected
     - ✅ "Checkout Windows-style, commit Unix-style line endings" is selected

3. **Verify Installation:**
   Open PowerShell or Command Prompt and run:
   ```powershell
   git --version
   ```
   You should see something like: `git version 2.xx.x`

---

## Step 2: Install Docker Desktop

Docker Desktop is required to run all the services in containers.

### Installation Steps:

1. **Download Docker Desktop:**
   - Visit: https://www.docker.com/products/docker-desktop/
   - Click "Download for Windows"
   - Download the installer (Docker Desktop Installer.exe)

2. **Run the Installer:**
   - Double-click the downloaded installer
   - Follow the installation wizard
   - **Important:** Make sure to check:
     - ✅ "Use WSL 2 instead of Hyper-V" (if available)
     - ✅ "Add shortcut to desktop"

3. **Start Docker Desktop:**
   - After installation, launch Docker Desktop from the Start menu
   - Wait for Docker to start (you'll see a whale icon in the system tray)
   - Docker Desktop may ask you to restart your computer - do so if prompted

4. **Verify Installation:**
   Open PowerShell and run:
   ```powershell
   docker --version
   docker-compose --version
   ```
   You should see version numbers for both commands.

5. **Verify Docker is Running:**
   ```powershell
   docker ps
   ```
   This should show an empty list (no error messages).

---

## Step 3: Install Make (Optional but Recommended)

Make is a build automation tool that simplifies running commands.

### Option A: Using Chocolatey (Recommended)

1. **Install Chocolatey (if not already installed):**
   - Open PowerShell as Administrator
   - Run:
     ```powershell
     Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
     ```

2. **Install Make:**
   ```powershell
   choco install make
   ```

3. **Verify Installation:**
   ```powershell
   make --version
   ```

### Option B: Using Scoop

1. **Install Scoop (if not already installed):**
   - Open PowerShell and run:
     ```powershell
     Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
     irm get.scoop.sh | iex
     ```

2. **Install Make:**
   ```powershell
   scoop install make
   ```

### Option C: Manual Installation (Without Package Manager)

1. **Download Make for Windows:**
   - Visit: http://gnuwin32.sourceforge.net/packages/make.htm
   - Download the "Complete package, except sources" installer

2. **Install:**
   - Run the installer
   - Add the installation directory to your PATH environment variable

---

## Step 4: Clone the Repository

1. **Open PowerShell or Git Bash**

2. **Navigate to where you want the project:**
   ```powershell
   cd Documents
   # or wherever you want to store the project
   ```

3. **Clone the repository:**
   ```powershell
   git clone git@github.com:sainathyai/Z2RWander.git
   ```
   
   **If SSH is not set up, use HTTPS instead:**
   ```powershell
   git clone https://github.com/sainathyai/Z2RWander.git
   ```

4. **Navigate into the project:**
   ```powershell
   cd Z2RWander
   ```

---

## Step 5: Verify Everything is Ready

Run these commands to verify your setup:

```powershell
# Check Git
git --version

# Check Docker
docker --version
docker-compose --version

# Check Docker is running
docker ps

# Check Make (if installed)
make --version

# Verify you're in the project directory
pwd
# Should show: ...\Z2RWander
```

---

## Step 6: Start the Development Environment

### If you have Make installed:

```powershell
make dev
```

### If you don't have Make:

```powershell
cd infrastructure
docker-compose up -d
```

---

## What Happens When You Run `make dev`

Here's what `make dev` does automatically:

### 1. **Dependency Check** (`check-deps`)
   - Verifies Docker is installed
   - Verifies Docker is running
   - Verifies Docker Compose is installed
   - Shows error messages if anything is missing

### 2. **Service Startup** (Full Stack Profile)
   The following services are started in order:

   **a. PostgreSQL Database:**
   - Pulls `postgres:15-alpine` image (if not already downloaded)
   - Creates a container named `wander-postgres`
   - Starts on port `5432`
   - Creates database `wander_dev`
   - Runs health checks
   - Mounts volume for data persistence

   **b. Redis Cache:**
   - Pulls `redis:7-alpine` image (if not already downloaded)
   - Creates a container named `wander-redis`
   - Starts on port `6379`
   - Runs health checks
   - Mounts volume for data persistence

   **c. Backend API:**
   - Builds Docker image from `backend/Dockerfile.dev`
   - Installs Node.js dependencies (`npm install`)
   - Creates a container named `wander-backend`
   - Starts on port `8080`
   - Waits for PostgreSQL and Redis to be healthy
   - Connects to database and cache
   - Runs TypeScript compilation
   - Starts the development server with hot reload

   **d. Frontend:**
   - Builds Docker image from `frontend/Dockerfile.dev`
   - Installs Node.js dependencies (`npm install`)
   - Creates a container named `wander-frontend`
   - Starts on port `3000`
   - Waits for backend to be ready
   - Starts Vite development server with hot reload

### 3. **Health Checks**
   - Waits 5 seconds for services to initialize
   - Checks status of all containers
   - Displays service status

### 4. **Network Setup**
   - Creates a Docker network `infrastructure_wander-network`
   - All services can communicate using service names (e.g., `backend`, `frontend`, `postgres`, `redis`)

### 5. **Volume Creation**
   - Creates `infrastructure_postgres_data` volume for database persistence
   - Creates `infrastructure_redis_data` volume for cache persistence

---

## Expected Output

When `make dev` runs successfully, you should see:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🚀 Starting Full Stack Profile...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Services to start:
   • PostgreSQL (Database)
   • Redis (Cache)
   • Backend API (Node.js)
   • Frontend (React)

✅ Services starting...
⏳ Waiting for services to be healthy...

[Container status output]
```

---

## Access Your Application

Once everything is running:

- **Frontend Dashboard:** http://localhost:3000
- **Backend API:** http://localhost:8080
- **Health Check:** http://localhost:8080/health
- **API Dashboard:** http://localhost:8080/dashboard

---

## Troubleshooting

### Docker Desktop Not Starting
- Make sure virtualization is enabled in BIOS
- Check Windows features: Enable "Virtual Machine Platform" and "Windows Subsystem for Linux"
- Restart your computer

### Port Already in Use
If you see errors about ports being in use:
```powershell
# Check what's using the port
netstat -ano | findstr :3000
netstat -ano | findstr :8080
netstat -ano | findstr :5432
netstat -ano | findstr :6379
```

### Permission Denied Errors
- Make sure Docker Desktop is running
- Try running PowerShell as Administrator
- Check Docker Desktop settings → Resources → File Sharing

### Make Command Not Found
- If you didn't install Make, use `docker-compose` commands directly:
  ```powershell
  cd infrastructure
  docker-compose up -d
  ```

### Services Not Starting
- Check Docker Desktop is running
- Check logs: `docker-compose logs` (from infrastructure directory)
- Try rebuilding: `docker-compose up -d --build`

---

## Next Steps

After successful setup:
1. Open http://localhost:3000 in your browser
2. Explore the developer dashboard
3. Check the connection endpoints
4. Review installed packages and versions
5. Start developing!

---

## Quick Reference Commands

```powershell
# Start everything
make dev
# or: cd infrastructure && docker-compose up -d

# Stop everything (keeps data)
make down
# or: cd infrastructure && docker-compose down

# Stop and remove everything
make teardown
# or: cd infrastructure && docker-compose down -v --rmi all --remove-orphans

# View logs
make logs
# or: cd infrastructure && docker-compose logs -f

# Check status
make status
# or: cd infrastructure && docker-compose ps
```

---

## Need Help?

If you encounter issues:
1. Check the [Troubleshooting Guide](../docs/TROUBLESHOOTING.md)
2. Review Docker Desktop logs
3. Check service logs: `docker-compose logs [service-name]`
4. Verify all prerequisites are installed correctly

