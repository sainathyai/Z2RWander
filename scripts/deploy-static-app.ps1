# Deploy static app to EKS
# Prerequisites: kubectl access to EKS cluster

Write-Host "🚀 Deploying static app to EKS..." -ForegroundColor Cyan

# Check kubectl access
Write-Host "`nChecking kubectl access..." -ForegroundColor Yellow
$kubectlCheck = kubectl cluster-info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ kubectl access failed. Please fix kubectl access first." -ForegroundColor Red
    Write-Host "See DEPLOYMENT_STATUS.md for instructions." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ kubectl access confirmed" -ForegroundColor Green

# Create namespace if it doesn't exist
Write-Host "`nCreating namespace..." -ForegroundColor Yellow
kubectl create namespace wander --dry-run=client -o yaml | kubectl apply -f -

# Apply manifests
Write-Host "`nApplying Kubernetes manifests..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/services/static-app-service.yaml
kubectl apply -f k8s/deployments/static-app-deployment.yaml

Write-Host "`n✅ Deployment initiated!" -ForegroundColor Green

# Wait for pods
Write-Host "`nWaiting for pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=static-app -n wander --timeout=120s

# Show status
Write-Host "`n📊 Deployment Status:" -ForegroundColor Cyan
kubectl get pods -n wander -l app=static-app
kubectl get svc -n wander

Write-Host "`n✅ Deployment complete!" -ForegroundColor Green
Write-Host "`nTo access the app:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward -n wander svc/static-app-service 8080:80" -ForegroundColor White
Write-Host "  Then open: http://localhost:8080" -ForegroundColor White

