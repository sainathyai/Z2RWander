# Wander Developer Environment - Prerequisites Installation Script (PowerShell)
# This script installs Git, Docker Desktop, and Make on Windows

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "Warning: $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "Info: $Message" -ForegroundColor Blue
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Check if Chocolatey is installed
function Test-Chocolatey {
    # First check if choco command is available
    if (Test-Command "choco") {
        return $true
    }
    
    # Check if Chocolatey is installed in the default location
    $chocoPath = "${env:ProgramData}\chocolatey\choco.exe"
    if (Test-Path $chocoPath) {
        # Add to PATH for this session
        $chocoBinPath = "${env:ProgramData}\chocolatey\bin"
        if ($env:Path -notlike "*$chocoBinPath*") {
            $env:Path = "$chocoBinPath;$env:Path"
        }
        return $true
    }
    
    return $false
}

# Get Chocolatey command (handles both PATH and direct path)
function Get-ChocoCommand {
    if (Test-Command "choco") {
        return "choco"
    }
    
    $chocoPath = "${env:ProgramData}\chocolatey\choco.exe"
    if (Test-Path $chocoPath) {
        return $chocoPath
    }
    
    return $null
}

# Install Chocolatey
function Install-Chocolatey {
    if (Test-Chocolatey) {
        $chocoCmd = Get-ChocoCommand
        if ($chocoCmd) {
            $chocoVersion = & $chocoCmd --version
            Write-Info "Chocolatey is already installed (version $chocoVersion). Upgrading to ensure latest version..."
            
            try {
                Write-Info "Upgrading Chocolatey..."
                & $chocoCmd upgrade chocolatey -y 2>&1 | Out-Null
                Start-Sleep -Seconds 2
                
                # Refresh PATH after upgrade
                $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
                $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
                $env:Path = $machinePath + ';' + $userPath
                
                $chocoBinPath = "${env:ProgramData}\chocolatey\bin"
                if (Test-Path $chocoBinPath) {
                    if ($env:Path -notlike "*$chocoBinPath*") {
                        $env:Path = "$chocoBinPath;$env:Path"
                    }
                }
                
                $newVersion = & $chocoCmd --version
                Write-Success "Chocolatey upgraded successfully (version $newVersion)"
                return $true
            } catch {
                Write-Warning-Custom "Chocolatey upgrade failed, but existing installation will be used"
                Write-Success "Chocolatey is available (version $chocoVersion)"
                return $true
            }
        }
    }

    Write-Info "Installing Chocolatey..."
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment variables
        $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
        $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        $env:Path = $machinePath + ';' + $userPath
        
        # Add Chocolatey bin to PATH if it exists
        $chocoBinPath = "${env:ProgramData}\chocolatey\bin"
        if (Test-Path $chocoBinPath) {
            if ($env:Path -notlike "*$chocoBinPath*") {
                $env:Path = "$chocoBinPath;$env:Path"
            }
        }
        
        if (Test-Chocolatey) {
            Write-Success "Chocolatey installed successfully"
            return $true
        } else {
            Write-Warning-Custom "Chocolatey installation may require a new PowerShell session"
            return $false
        }
    } catch {
        Write-Error "Failed to install Chocolatey: $_"
        return $false
    }
}

# Install Git
function Install-Git {
    $chocoCmd = Get-ChocoCommand
    
    # Check if Git is already installed
    if (Test-Command "git") {
        $gitVersion = git --version
        Write-Info "Git is already installed ($gitVersion). Upgrading to ensure latest version..."
        
        # Upgrade Git via Chocolatey
        if (Test-Chocolatey -and $chocoCmd) {
            try {
                Write-Info "Upgrading Git via Chocolatey..."
                & $chocoCmd upgrade git -y
                
                # Refresh PATH
                $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
                $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
                $env:Path = $machinePath + ';' + $userPath
                
                # Wait for PATH to update
                Start-Sleep -Seconds 2
                $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
                
                if (Test-Command "git") {
                    $newVersion = git --version
                    Write-Success "Git upgraded successfully ($newVersion)"
                    return $true
                }
            } catch {
                Write-Warning-Custom "Git upgrade failed, but existing installation will be used"
                Write-Success "Git is available ($gitVersion)"
                return $true
            }
        } else {
            Write-Success "Git is installed ($gitVersion)"
            return $true
        }
    }

    Write-Info "Installing Git..."

    if (Test-Chocolatey -and $chocoCmd) {
        try {
            & $chocoCmd install git -y
            # Refresh PATH
            $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
            $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
            $env:Path = $machinePath + ';' + $userPath
            
            # Wait for PATH to update
            Start-Sleep -Seconds 2
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
            
            if (Test-Command "git") {
                $gitVersion = git --version
                Write-Success "Git installed successfully ($gitVersion)"
                return $true
            }
        } catch {
            Write-Warning-Custom "Chocolatey installation failed. Trying manual download..."
        }
    }

    Write-Warning-Custom "Git installation via Chocolatey failed or Chocolatey not available"
    Write-Info "Please install Git manually:"
    Write-Info "  1. Download from: https://git-scm.com/download/win"
    Write-Info "  2. Run the installer with default options"
    return $false
}

# Install Docker Desktop
function Install-DockerDesktop {
    $chocoCmd = Get-ChocoCommand
    $dockerDesktopPath = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
    
    # Check if Docker Desktop is already installed
    if (Test-Path $dockerDesktopPath) {
        Write-Info "Docker Desktop is already installed. Upgrading to ensure latest version..."
        
        # Check if Docker is running and stop it if needed
        if (Test-Command "docker") {
            try {
                docker info | Out-Null 2>&1 | Out-Null
                Write-Info "Stopping Docker Desktop for upgrade..."
                Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 3
            } catch {
                Write-Info "Docker Desktop is not running"
            }
        }
        
        # Upgrade Docker Desktop via Chocolatey
        if (Test-Chocolatey -and $chocoCmd) {
            try {
                Write-Info "Upgrading Docker Desktop via Chocolatey..."
                & $chocoCmd upgrade docker-desktop -y
                
                if (Test-Path $dockerDesktopPath) {
                    Write-Success "Docker Desktop upgraded successfully"
                    Write-Warning-Custom "Docker Desktop may require a restart to complete upgrade"
                    Write-Info "Please start Docker Desktop from the Start menu after restart (if needed)"
                    return $true
                }
            } catch {
                Write-Warning-Custom "Chocolatey upgrade failed. Docker Desktop may need manual upgrade."
            }
        }
        
        # If upgrade didn't work, check if it's still functional
        if (Test-Command "docker") {
            try {
                docker info | Out-Null
                Write-Success "Docker Desktop is installed and functional"
                return $true
            } catch {
                Write-Warning-Custom "Docker Desktop is installed but not running"
                Write-Info "Please start Docker Desktop from the Start menu"
                return $true
            }
        }
        return $true
    }

    Write-Info "Installing Docker Desktop..."

    if (Test-Chocolatey -and $chocoCmd) {
        try {
            & $chocoCmd install docker-desktop -y
            
            if (Test-Path $dockerDesktopPath) {
                Write-Success "Docker Desktop installed successfully"
                Write-Warning-Custom "Docker Desktop requires a restart to complete installation"
                Write-Info "After restart, start Docker Desktop from the Start menu"
                return $true
            }
        } catch {
            Write-Warning-Custom "Chocolatey installation failed. Trying manual download..."
        }
    }

    Write-Warning-Custom "Docker Desktop installation via Chocolatey failed or Chocolatey not available"
    Write-Info "Please install Docker Desktop manually:"
    Write-Info "  1. Download from: https://www.docker.com/products/docker-desktop/"
    Write-Info "  2. Run the installer"
    Write-Info "  3. Restart your computer if prompted"
    Write-Info "  4. Start Docker Desktop from the Start menu"
    return $false
}

# Install Make
function Install-Make {
    # First, ensure Chocolatey is available
    if (-not (Test-Chocolatey)) {
        Write-Info "Chocolatey is required to install Make. Installing Chocolatey first..."
        Install-Chocolatey | Out-Null
    }

    $chocoCmd = Get-ChocoCommand
    if (-not $chocoCmd) {
        Write-Error "Chocolatey command not found. Cannot install Make."
        return $false
    }

    # Check if Make is already installed
    if (Test-Command "make") {
        $makeVersion = make --version | Select-Object -First 1
        Write-Info "Make is already installed ($makeVersion). Reinstalling to ensure latest version..."
        
        # Uninstall existing Make
        try {
            Write-Info "Uninstalling existing Make..."
            & $chocoCmd uninstall make -y 2>&1 | Out-Null
            Start-Sleep -Seconds 2
            
            # Refresh PATH after uninstall
            $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
            $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
            $env:Path = $machinePath + ';' + $userPath
        } catch {
            Write-Warning-Custom "Could not uninstall Make via Chocolatey (may be installed manually)"
        }
    }

    Write-Info "Installing Make (required tool)..."

    if (Test-Chocolatey) {
        try {
            Write-Info "Installing Make via Chocolatey..."
            $chocoOutput = & $chocoCmd install make -y 2>&1
            $chocoExitCode = $LASTEXITCODE
            
            # Refresh PATH multiple times to ensure it's updated
            $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
            $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
            $env:Path = $machinePath + ';' + $userPath
            
            # Wait a moment for PATH to propagate
            Start-Sleep -Seconds 2
            
            # Refresh PATH again
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
            
            # Try to find make in common installation paths
            $chocoPath = "${env:ProgramData}\chocolatey\bin"
            if (Test-Path "$chocoPath\make.exe") {
                $env:Path = "$chocoPath;$env:Path"
            }
            
            # Test if make is now available
            if (Test-Command "make") {
                $makeVersion = make --version | Select-Object -First 1
                Write-Success "Make installed successfully ($makeVersion)"
                return $true
            } else {
                Write-Warning-Custom "Make installation completed but not found in PATH. You may need to restart PowerShell."
                # Try one more time after a longer wait
                Start-Sleep -Seconds 3
                $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
                if (Test-Path "$chocoPath\make.exe") {
                    $env:Path = "$chocoPath;$env:Path"
                }
                if (Test-Command "make") {
                    $makeVersion = make --version | Select-Object -First 1
                    Write-Success "Make installed successfully ($makeVersion)"
                    return $true
                }
            }
        } catch {
            Write-Warning-Custom "Chocolatey installation failed: $_"
        }
    }

    # Try Scoop as alternative
    if (Test-Command "scoop") {
        try {
            Write-Info "Trying to install Make via Scoop..."
            scoop install make
            Start-Sleep -Seconds 2
            if (Test-Command "make") {
                $makeVersion = make --version | Select-Object -First 1
                Write-Success "Make installed successfully via Scoop ($makeVersion)"
                return $true
            }
        } catch {
            Write-Warning-Custom "Scoop installation failed: $_"
        }
    }

    Write-Error "Make installation failed. Make is required for this project."
    Write-Info "Please install Make manually using one of these methods:"
    Write-Info "  1. Run: choco install make -y (in Administrator PowerShell)"
    Write-Info "  2. Install via Scoop: scoop install make"
    Write-Info "  3. Download from: http://gnuwin32.sourceforge.net/packages/make.htm"
    Write-Info ""
    Write-Info "After installation, close and reopen PowerShell to refresh PATH."
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
            Write-Warning-Custom "Docker: Installed but not running"
            Write-Info "Please start Docker Desktop from the Start menu"
        }
    } else {
        Write-Error "Docker: Not installed"
        $allOk = $false
    }
    
    if (Test-Command "docker-compose") {
        $composeVersion = docker-compose --version
        Write-Success "Docker Compose: $composeVersion"
    } else {
        # Check for Docker Compose V2 (docker compose as subcommand)
        $composeCheck = docker compose version 2>&1
        if ($? -and $composeCheck -notmatch 'error|not found') {
            Write-Success "Docker Compose: $composeCheck"
        } else {
            Write-Warning-Custom "Docker Compose: Not found (should be included with Docker Desktop)"
        }
    }
    
    if (Test-Command "make") {
        $makeVersion = make --version | Select-Object -First 1
        Write-Success "Make: $makeVersion"
    } else {
        Write-Error "Make: Not installed (REQUIRED)"
        $allOk = $false
    }
    
    Write-Host ""
    if ($allOk) {
        Write-Success "All required tools are installed!"
        return $true
    } else {
        Write-Error "Some required tools are missing. Please install them manually."
        Write-Error "The script will exit with an error. Please fix the issues above and try again."
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
    
    # Install Make (required)
    $makeInstalled = Install-Make
    if (-not $makeInstalled) {
        Write-Error "Make installation failed. This is a required tool."
        Write-Info "Please install Make manually and run this script again."
        exit 1
    }
    
    # Verify all installations
    $allInstalled = Test-Installations
    if (-not $allInstalled) {
        Write-Error "Some required tools are missing. Please install them and try again."
        exit 1
    }
    
    Write-Header "Installation Complete"
    Write-Success "Prerequisites installation finished!"
    Write-Host ""
    Write-Info 'Next steps:'
    Write-Host '  1. If Docker Desktop was just installed, restart your computer'
    Write-Host '  2. Start Docker Desktop from the Start menu'
    Write-Host '  3. Wait for Docker Desktop to fully start (whale icon in system tray)'
    Write-Host '  4. Close and reopen PowerShell to refresh PATH (if Make was just installed)'
    Write-Host '  5. Navigate to the project: cd Z2RWander'
    Write-Host '  6. Start the environment: make dev'
    Write-Host ""
}

# Run main function
Main

