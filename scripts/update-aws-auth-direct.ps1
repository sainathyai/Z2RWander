# Direct update of aws-auth using AWS CLI and kubectl with service account token
$CLUSTER_NAME = "dev-env-cluster"
$REGION = "us-east-1"
$USER_ARN = "arn:aws:iam::971422717446:user/sainatha.yatham@gmail.com"

Write-Host "🔧 Attempting to update aws-auth ConfigMap..." -ForegroundColor Cyan

# Try using kubectl with --validate=false to bypass validation
Write-Host "`nTrying kubectl apply with --validate=false..." -ForegroundColor Yellow
kubectl apply -f aws-auth-update.yaml --validate=false --server-side 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Successfully updated aws-auth!" -ForegroundColor Green
    Write-Host "`nWaiting 5 seconds for changes to propagate..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    Write-Host "`nTesting kubectl access..." -ForegroundColor Cyan
    kubectl get nodes 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ kubectl access confirmed!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  kubectl still not working. May need to wait longer or use eksctl." -ForegroundColor Yellow
    }
} else {
    Write-Host "`n❌ Direct update failed. Trying alternative methods..." -ForegroundColor Red
    
    Write-Host "`nOption 1: Use AWS Console" -ForegroundColor Cyan
    Write-Host "1. Go to: https://console.aws.amazon.com/eks/home?region=us-east-1#/clusters/dev-env-cluster" -ForegroundColor White
    Write-Host "2. Click 'Access' tab" -ForegroundColor White
    Write-Host "3. Click 'Add user' and add your IAM user" -ForegroundColor White
    
    Write-Host "`nOption 2: Install eksctl and run:" -ForegroundColor Cyan
    Write-Host "eksctl create iamidentitymapping --cluster $CLUSTER_NAME --region $REGION --arn $USER_ARN --group system:masters --username admin" -ForegroundColor White
}

