# Script to fix kubectl access to EKS cluster
# This adds the current AWS user to the cluster's aws-auth ConfigMap

$CLUSTER_NAME = "dev-env-cluster"
$REGION = "us-east-1"

Write-Host "🔧 Fixing kubectl access to EKS cluster: $CLUSTER_NAME" -ForegroundColor Yellow

# Get current AWS user ARN
$USER_ARN = (aws sts get-caller-identity --query Arn --output text)
Write-Host "Current user ARN: $USER_ARN" -ForegroundColor Cyan

# Try to get aws-auth ConfigMap (this might fail if we don't have access)
Write-Host "`nAttempting to update aws-auth ConfigMap..." -ForegroundColor Yellow

# Create a temporary file with the aws-auth update
$AUTH_UPDATE = @"
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: $USER_ARN
      username: admin
      groups:
        - system:masters
"@

$TEMP_FILE = "$env:TEMP\aws-auth-update.yaml"
$AUTH_UPDATE | Out-File -FilePath $TEMP_FILE -Encoding UTF8

Write-Host "`n⚠️  Note: You may need cluster admin access to update aws-auth." -ForegroundColor Yellow
Write-Host "`nTo fix kubectl access, run one of these:" -ForegroundColor Cyan
Write-Host "`nOption 1: If you have cluster admin access, run:" -ForegroundColor Green
Write-Host "  kubectl apply -f $TEMP_FILE" -ForegroundColor White
Write-Host "`nOption 2: Ask your cluster admin to add this user to aws-auth:" -ForegroundColor Green
Write-Host "  User ARN: $USER_ARN" -ForegroundColor White
Write-Host "  Username: admin" -ForegroundColor White
Write-Host "  Groups: system:masters" -ForegroundColor White
Write-Host "`nOption 3: Use AWS IAM Authenticator:" -ForegroundColor Green
Write-Host "  aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME --role-arn <admin-role-arn>" -ForegroundColor White

Write-Host "`nTemporary file created at: $TEMP_FILE" -ForegroundColor Cyan

