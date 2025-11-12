#!/bin/bash

# Wander Developer Environment - Prerequisites Installation Script
# This script installs Git, Docker, and Make on Linux/WSL/Git Bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
            OS_VERSION=$VERSION_ID
        else
            print_error "Cannot detect Linux distribution"
            exit 1
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
        print_warning "Windows detected. This script works best in WSL or Git Bash."
        print_info "For native Windows, use install-prerequisites.ps1 instead"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root. Some installations may not work correctly."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Install Git
install_git() {
    if command_exists git; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_success "Git is already installed (version $GIT_VERSION)"
        return 0
    fi

    print_info "Installing Git..."

    case $OS in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y git
            ;;
        fedora|rhel|centos)
            sudo dnf install -y git || sudo yum install -y git
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm git
            ;;
        macos)
            if command_exists brew; then
                brew install git
            else
                print_error "Homebrew not found. Please install Homebrew first: https://brew.sh"
                return 1
            fi
            ;;
        windows)
            print_warning "Git installation on Windows requires manual download."
            print_info "Please download from: https://git-scm.com/download/win"
            return 1
            ;;
        *)
            print_error "Unsupported OS for Git installation: $OS"
            return 1
            ;;
    esac

    if command_exists git; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_success "Git installed successfully (version $GIT_VERSION)"
    else
        print_error "Git installation failed"
        return 1
    fi
}

# Install Docker
install_docker() {
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker is already installed (version $DOCKER_VERSION)"
        
        # Check if Docker daemon is running
        if docker info >/dev/null 2>&1; then
            print_success "Docker daemon is running"
        else
            print_warning "Docker is installed but daemon is not running"
            print_info "Please start Docker Desktop or Docker daemon"
        fi
        return 0
    fi

    print_info "Installing Docker..."

    case $OS in
        ubuntu|debian)
            # Remove old versions
            sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
            
            # Install prerequisites
            sudo apt-get update
            sudo apt-get install -y \
                ca-certificates \
                curl \
                gnupg \
                lsb-release
            
            # Add Docker's official GPG key
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            
            # Set up repository
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
              $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # Install Docker Engine
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            
            # Add current user to docker group
            sudo usermod -aG docker $USER
            print_warning "Added $USER to docker group. You may need to log out and back in."
            ;;
        fedora)
            # Remove old versions
            sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine 2>/dev/null || true
            
            # Install prerequisites
            sudo dnf install -y dnf-plugins-core
            
            # Add Docker repository
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            
            # Install Docker Engine
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            
            # Start Docker
            sudo systemctl start docker
            sudo systemctl enable docker
            
            # Add current user to docker group
            sudo usermod -aG docker $USER
            print_warning "Added $USER to docker group. You may need to log out and back in."
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm docker docker-compose
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            print_warning "Added $USER to docker group. You may need to log out and back in."
            ;;
        macos)
            print_warning "Docker Desktop for Mac requires manual installation."
            print_info "Please download from: https://www.docker.com/products/docker-desktop/"
            return 1
            ;;
        windows)
            print_warning "Docker Desktop for Windows requires manual installation."
            print_info "Please download from: https://www.docker.com/products/docker-desktop/"
            return 1
            ;;
        *)
            print_error "Unsupported OS for Docker installation: $OS"
            return 1
            ;;
    esac

    if command_exists docker; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker installed successfully (version $DOCKER_VERSION)"
    else
        print_error "Docker installation failed"
        return 1
    fi
}

# Install Docker Compose
install_docker_compose() {
    # Check if docker compose plugin is available (newer method)
    if docker compose version >/dev/null 2>&1; then
        COMPOSE_VERSION=$(docker compose version | cut -d' ' -f4)
        print_success "Docker Compose plugin is already installed (version $COMPOSE_VERSION)"
        return 0
    fi
    
    # Check if docker-compose standalone is available
    if command_exists docker-compose; then
        COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f4 | cut -d',' -f1)
        print_success "Docker Compose is already installed (version $COMPOSE_VERSION)"
        return 0
    fi

    print_info "Docker Compose should be installed with Docker. Checking..."

    # For most modern installations, docker compose is a plugin
    # If not available, we'll install it separately
    case $OS in
        ubuntu|debian|fedora|arch|manjaro)
            # Docker Compose plugin should be installed with Docker
            print_info "Docker Compose plugin should be available. If not, it will be installed with Docker."
            ;;
        macos|windows)
            print_info "Docker Compose is included with Docker Desktop"
            ;;
    esac
}

# Install Make
install_make() {
    if command_exists make; then
        MAKE_VERSION=$(make --version | head -n1 | cut -d' ' -f3)
        print_success "Make is already installed (version $MAKE_VERSION)"
        return 0
    fi

    print_info "Installing Make..."

    case $OS in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y make
            ;;
        fedora|rhel|centos)
            sudo dnf install -y make || sudo yum install -y make
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm make
            ;;
        macos)
            if command_exists brew; then
                brew install make
            else
                # Make usually comes with Xcode Command Line Tools
                xcode-select --install 2>/dev/null || print_warning "Please install Xcode Command Line Tools"
            fi
            ;;
        windows)
            print_warning "Make installation on Windows requires manual setup."
            print_info "Options:"
            print_info "  1. Install via Chocolatey: choco install make"
            print_info "  2. Install via Scoop: scoop install make"
            print_info "  3. Download from: http://gnuwin32.sourceforge.net/packages/make.htm"
            return 1
            ;;
        *)
            print_error "Unsupported OS for Make installation: $OS"
            return 1
            ;;
    esac

    if command_exists make; then
        MAKE_VERSION=$(make --version | head -n1 | cut -d' ' -f3)
        print_success "Make installed successfully (version $MAKE_VERSION)"
    else
        print_error "Make installation failed"
        return 1
    fi
}

# Verify installations
verify_installations() {
    print_header "Verifying Installations"
    
    local all_ok=true
    
    if command_exists git; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_success "Git: $GIT_VERSION"
    else
        print_error "Git: Not installed"
        all_ok=false
    fi
    
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker: $DOCKER_VERSION"
        
        if docker info >/dev/null 2>&1; then
            print_success "Docker daemon: Running"
        else
            print_warning "Docker daemon: Not running (start Docker Desktop or daemon)"
        fi
    else
        print_error "Docker: Not installed"
        all_ok=false
    fi
    
    if docker compose version >/dev/null 2>&1 || command_exists docker-compose; then
        if docker compose version >/dev/null 2>&1; then
            COMPOSE_VERSION=$(docker compose version | cut -d' ' -f4)
        else
            COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f4 | cut -d',' -f1)
        fi
        print_success "Docker Compose: $COMPOSE_VERSION"
    else
        print_error "Docker Compose: Not installed"
        all_ok=false
    fi
    
    if command_exists make; then
        MAKE_VERSION=$(make --version | head -n1 | cut -d' ' -f3)
        print_success "Make: $MAKE_VERSION"
    else
        print_warning "Make: Not installed (optional, but recommended)"
    fi
    
    echo ""
    if [ "$all_ok" = true ]; then
        print_success "All required tools are installed!"
        return 0
    else
        print_error "Some required tools are missing. Please install them manually."
        return 1
    fi
}

# Main execution
main() {
    print_header "Wander Developer Environment - Prerequisites Installation"
    
    detect_os
    print_info "Detected OS: $OS"
    
    check_root
    
    print_header "Installing Prerequisites"
    
    # Install Git
    install_git || print_warning "Git installation skipped or failed"
    
    # Install Docker
    install_docker || print_warning "Docker installation skipped or failed"
    
    # Install Docker Compose (usually comes with Docker)
    install_docker_compose || print_warning "Docker Compose check skipped"
    
    # Install Make
    install_make || print_warning "Make installation skipped (optional)"
    
    # Verify
    verify_installations
    
    print_header "Installation Complete"
    print_success "Prerequisites installation finished!"
    echo ""
    print_info "Next steps:"
    echo "  1. If Docker was just installed, you may need to log out and back in"
    echo "  2. Start Docker Desktop or Docker daemon"
    echo "  3. Clone the repository: git clone git@github.com:sainathyai/Z2RWander.git"
    echo "  4. Navigate to the project: cd Z2RWander"
    echo "  5. Start the environment: make dev"
    echo ""
}

# Run main function
main "$@"

