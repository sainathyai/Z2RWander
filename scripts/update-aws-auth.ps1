# Update aws-auth ConfigMap to add current user
$CLUSTER_NAME = "dev-env-cluster"
$REGION = "us-east-1"
$NAMESPACE = "kube-system"
$CONFIGMAP_NAME = "aws-auth"

Write-Host "🔧 Updating aws-auth ConfigMap for cluster: $CLUSTER_NAME" -ForegroundColor Cyan

# Get current user ARN
$USER_ARN = aws sts get-caller-identity --query Arn --output text
Write-Host "Current user ARN: $USER_ARN" -ForegroundColor Yellow

# Try to get existing ConfigMap
Write-Host "`nFetching existing aws-auth ConfigMap..." -ForegroundColor Yellow
$EXISTING_CM = kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o yaml 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Found existing ConfigMap, updating..." -ForegroundColor Green
    
    # Save to temp file
    $TEMP_FILE = "$env:TEMP\aws-auth-existing.yaml"
    $EXISTING_CM | Out-File -FilePath $TEMP_FILE -Encoding UTF8
    
    # Check if user already exists
    if ($EXISTING_CM -match [regex]::Escape($USER_ARN)) {
        Write-Host "⚠️  User already exists in aws-auth" -ForegroundColor Yellow
    } else {
        Write-Host "Adding user to existing ConfigMap..." -ForegroundColor Yellow
        
        # Create updated ConfigMap with user added
        $UPDATED_CM = $EXISTING_CM -replace '(data:.*mapUsers: \|)', "`$1`n    - userarn: $USER_ARN`n      username: admin`n      groups:`n        - system:masters"
        
        $UPDATED_FILE = "$env:TEMP\aws-auth-updated.yaml"
        $UPDATED_CM | Out-File -FilePath $UPDATED_FILE -Encoding UTF8
        
        # Apply updated ConfigMap
        kubectl apply -f $UPDATED_FILE
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully updated aws-auth ConfigMap!" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to update ConfigMap" -ForegroundColor Red
        }
    }
} else {
    Write-Host "⚠️  ConfigMap not found or cannot access. Creating new one..." -ForegroundColor Yellow
    
    # Create new ConfigMap
    $NEW_CM = @"
apiVersion: v1
kind: ConfigMap
metadata:
  name: $CONFIGMAP_NAME
  namespace: $NAMESPACE
data:
  mapUsers: |
    - userarn: $USER_ARN
      username: admin
      groups:
        - system:masters
"@
    
    $NEW_FILE = "$env:TEMP\aws-auth-new.yaml"
    $NEW_CM | Out-File -FilePath $NEW_FILE -Encoding UTF8
    
    kubectl apply -f $NEW_FILE
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully created aws-auth ConfigMap!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create ConfigMap. You may need cluster admin access." -ForegroundColor Red
        Write-Host "`nTry running this manually:" -ForegroundColor Yellow
        Write-Host "kubectl apply -f $NEW_FILE" -ForegroundColor White
    }
}

Write-Host "`nTesting kubectl access..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
kubectl get nodes 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ kubectl access confirmed!" -ForegroundColor Green
} else {
    Write-Host "⚠️  kubectl access still not working. May need to wait a few seconds or check permissions." -ForegroundColor Yellow
}

