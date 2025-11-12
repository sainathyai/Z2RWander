# PowerShell test script for Windows
# Quick validation tests

Write-Host "🧪 Running Windows Compatibility Tests..." -ForegroundColor Cyan
Write-Host ""

$FAILED = 0
$PASSED = 0

function Test-Command {
    param(
        [string]$Name,
        [string]$Command,
        [string]$ExpectedOutput = ""
    )
    
    try {
        $result = Invoke-Expression $Command 2>&1
        if ($LASTEXITCODE -eq 0 -or $result) {
            Write-Host "✅ $Name" -ForegroundColor Green
            $script:PASSED++
            return $true
        } else {
            Write-Host "❌ $Name" -ForegroundColor Red
            $script:FAILED++
            return $false
        }
    } catch {
        Write-Host "❌ $Name" -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Yellow
        $script:FAILED++
        return $false
    }
}

# Test Docker installation
Write-Host "Testing Docker Installation..." -ForegroundColor Blue
Test-Command "Docker installed" "docker --version"
Test-Command "Docker Compose installed" "docker-compose --version"

# Test Docker is running
Write-Host ""
Write-Host "Testing Docker Status..." -ForegroundColor Blue
Test-Command "Docker daemon running" "docker ps"

# Test Docker Compose config
Write-Host ""
Write-Host "Testing Configuration..." -ForegroundColor Blue
if (Test-Path "infrastructure\docker-compose.yml") {
    Push-Location infrastructure
    $configTest = docker-compose config --quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker Compose config valid" -ForegroundColor Green
        $PASSED++
    } else {
        Write-Host "❌ Docker Compose config invalid" -ForegroundColor Red
        Write-Host "   $configTest" -ForegroundColor Yellow
        $FAILED++
    }
    Pop-Location
} else {
    Write-Host "⚠️  docker-compose.yml not found" -ForegroundColor Yellow
}

# Test project structure
Write-Host ""
Write-Host "Testing Project Structure..." -ForegroundColor Blue
$requiredDirs = @("backend", "frontend", "infrastructure", "scripts", "docs")
foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "✅ $dir/ exists" -ForegroundColor Green
        $PASSED++
    } else {
        Write-Host "❌ $dir/ missing" -ForegroundColor Red
        $FAILED++
    }
}

# Test key files
Write-Host ""
Write-Host "Testing Key Files..." -ForegroundColor Blue
$requiredFiles = @(
    "Makefile",
    "README.md",
    "infrastructure\docker-compose.yml",
    "backend\package.json",
    "frontend\package.json"
)
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file exists" -ForegroundColor Green
        $PASSED++
    } else {
        Write-Host "❌ $file missing" -ForegroundColor Red
        $FAILED++
    }
}

# Summary
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
if ($FAILED -eq 0) {
    Write-Host "✅ All tests passed! ($PASSED tests)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ $FAILED test(s) failed, $PASSED test(s) passed" -ForegroundColor Red
    exit 1
}
