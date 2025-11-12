# Wander Developer Environment - Prerequisites Installation Script (PowerShell)
# This script installs Git, Docker Desktop, and Make on Windows

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Check if Chocolatey is installed
function Test-Chocolatey {
    Test-Command "choco"
}

# Install Chocolatey
function Install-Chocolatey {
    if (Test-Chocolatey) {
        $chocoVersion = choco --version
        Write-Success "Chocolatey is already installed (version $chocoVersion)"
        return $true
    }

    Write-Info "Installing Chocolatey..."
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        if (Test-Chocolatey) {
            Write-Success "Chocolatey installed successfully"
            return $true
        } else {
            Write-Warning "Chocolatey installation may require a new PowerShell session"
            return $false
        }
    } catch {
        Write-Error "Failed to install Chocolatey: $_"
        return $false
    }
}

# Install Git
function Install-Git {
    if (Test-Command "git") {
        $gitVersion = git --version
        Write-Success "Git is already installed ($gitVersion)"
        return $true
    }

    Write-Info "Installing Git..."

    if (Test-Chocolatey) {
        try {
            choco install git -y
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            if (Test-Command "git") {
                $gitVersion = git --version
                Write-Success "Git installed successfully ($gitVersion)"
                return $true
            }
        } catch {
            Write-Warning "Chocolatey installation failed. Trying manual download..."
        }
    }

    Write-Warning "Git installation via Chocolatey failed or Chocolatey not available"
    Write-Info "Please install Git manually:"
    Write-Info "  1. Download from: https://git-scm.com/download/win"
    Write-Info "  2. Run the installer with default options"
    return $false
}

# Install Docker Desktop
function Install-DockerDesktop {
    # Check if Docker Desktop is installed
    $dockerDesktopPath = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerDesktopPath) {
        Write-Success "Docker Desktop is already installed"
        
        # Check if Docker is running
        if (Test-Command "docker") {
            try {
                docker info | Out-Null
                Write-Success "Docker Desktop is running"
                return $true
            } catch {
                Write-Warning "Docker Desktop is installed but not running"
                Write-Info "Please start Docker Desktop from the Start menu"
                return $true
            }
        }
        return $true
    }

    Write-Info "Installing Docker Desktop..."

    if (Test-Chocolatey) {
        try {
            choco install docker-desktop -y
            
            if (Test-Path $dockerDesktopPath) {
                Write-Success "Docker Desktop installed successfully"
                Write-Warning "Docker Desktop requires a restart to complete installation"
                Write-Info "After restart, start Docker Desktop from the Start menu"
                return $true
            }
        } catch {
            Write-Warning "Chocolatey installation failed. Trying manual download..."
        }
    }

    Write-Warning "Docker Desktop installation via Chocolatey failed or Chocolatey not available"
    Write-Info "Please install Docker Desktop manually:"
    Write-Info "  1. Download from: https://www.docker.com/products/docker-desktop/"
    Write-Info "  2. Run the installer"
    Write-Info "  3. Restart your computer if prompted"
    Write-Info "  4. Start Docker Desktop from the Start menu"
    return $false
}

# Install Make
function Install-Make {
    if (Test-Command "make") {
        $makeVersion = make --version | Select-Object -First 1
        Write-Success "Make is already installed ($makeVersion)"
        return $true
    }

    Write-Info "Installing Make..."

    if (Test-Chocolatey) {
        try {
            choco install make -y
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            if (Test-Command "make") {
                $makeVersion = make --version | Select-Object -First 1
                Write-Success "Make installed successfully ($makeVersion)"
                return $true
            }
        } catch {
            Write-Warning "Chocolatey installation failed. Trying alternative methods..."
        }
    }

    # Try Scoop as alternative
    if (Test-Command "scoop") {
        try {
            scoop install make
            if (Test-Command "make") {
                Write-Success "Make installed successfully via Scoop"
                return $true
            }
        } catch {
            Write-Warning "Scoop installation failed"
        }
    }

    Write-Warning "Make installation via package managers failed"
    Write-Info "Make is optional but recommended. Installation options:"
    Write-Info "  1. Install via Chocolatey: choco install make"
    Write-Info "  2. Install via Scoop: scoop install make"
    Write-Info "  3. Download from: http://gnuwin32.sourceforge.net/packages/make.htm"
    Write-Info "  4. Or use docker-compose commands directly (no Make required)"
    return $false
}

# Verify installations
function Test-Installations {
    Write-Header "Verifying Installations"
    
    $allOk = $true
    
    if (Test-Command "git") {
        $gitVersion = git --version
        Write-Success "Git: $gitVersion"
    } else {
        Write-Error "Git: Not installed"
        $allOk = $false
    }
    
    if (Test-Command "docker") {
        try {
            $dockerVersion = docker --version
            Write-Success "Docker: $dockerVersion"
            
            docker info | Out-Null
            Write-Success "Docker Desktop: Running"
        } catch {
            Write-Warning "Docker: Installed but not running"
            Write-Info "Please start Docker Desktop from the Start menu"
        }
    } else {
        Write-Error "Docker: Not installed"
        $allOk = $false
    }
    
    if (Test-Command "docker-compose") {
        $composeVersion = docker-compose --version
        Write-Success "Docker Compose: $composeVersion"
    } elseif (docker compose version 2>$null) {
        $composeVersion = docker compose version
        Write-Success "Docker Compose: $composeVersion"
    } else {
        Write-Warning "Docker Compose: Not found (should be included with Docker Desktop)"
    }
    
    if (Test-Command "make") {
        $makeVersion = make --version | Select-Object -First 1
        Write-Success "Make: $makeVersion"
    } else {
        Write-Warning "Make: Not installed (optional, but recommended)"
    }
    
    Write-Host ""
    if ($allOk) {
        Write-Success "All required tools are installed!"
        return $true
    } else {
        Write-Error "Some required tools are missing. Please install them manually."
        return $false
    }
}

# Main execution
function Main {
    Write-Header "Wander Developer Environment - Prerequisites Installation (Windows)"
    
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Error "This script requires administrator privileges"
        Write-Info "Please run PowerShell as Administrator and try again"
        exit 1
    }
    
    Write-Info "Detected OS: Windows"
    
    Write-Header "Installing Prerequisites"
    
    # Install Chocolatey (needed for other installations)
    Install-Chocolatey | Out-Null
    
    # Install Git
    Install-Git | Out-Null
    
    # Install Docker Desktop
    Install-DockerDesktop | Out-Null
    
    # Install Make
    Install-Make | Out-Null
    
    # Verify
    Test-Installations | Out-Null
    
    Write-Header "Installation Complete"
    Write-Success "Prerequisites installation finished!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "  1. If Docker Desktop was just installed, restart your computer"
    Write-Host "  2. Start Docker Desktop from the Start menu"
    Write-Host "  3. Wait for Docker Desktop to fully start (whale icon in system tray)"
    Write-Host "  4. Open a new PowerShell window (to refresh PATH)"
    Write-Host "  5. Clone the repository: git clone git@github.com:sainathyai/Z2RWander.git"
    Write-Host "  6. Navigate to the project: cd Z2RWander"
    Write-Host "  7. Start the environment: make dev"
    Write-Host "     (or: cd infrastructure && docker-compose up -d)"
    Write-Host ""
}

# Run main function
Main

