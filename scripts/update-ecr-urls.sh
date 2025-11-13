#!/bin/bash

# Script to update ECR URLs in Kubernetes manifests
# Usage: ./scripts/update-ecr-urls.sh

set -e

AWS_REGION=${AWS_REGION:-us-east-1}

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "❌ Error: Could not get AWS account ID. Make sure AWS CLI is configured."
    exit 1
fi

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
BACKEND_IMAGE="${ECR_REGISTRY}/wander-backend:latest"
FRONTEND_IMAGE="${ECR_REGISTRY}/wander-frontend:latest"

echo "🔄 Updating ECR URLs in Kubernetes manifests..."
echo "   Backend:  ${BACKEND_IMAGE}"
echo "   Frontend: ${FRONTEND_IMAGE}"

# Update backend deployment
if [ -f "k8s/deployments/backend-deployment.yaml" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|YOUR_ECR_REGISTRY/wander-backend:latest|${BACKEND_IMAGE}|g" k8s/deployments/backend-deployment.yaml
    else
        # Linux
        sed -i "s|YOUR_ECR_REGISTRY/wander-backend:latest|${BACKEND_IMAGE}|g" k8s/deployments/backend-deployment.yaml
    fi
    echo "✅ Updated backend-deployment.yaml"
fi

# Update frontend deployment
if [ -f "k8s/deployments/frontend-deployment.yaml" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|YOUR_ECR_REGISTRY/wander-frontend:latest|${FRONTEND_IMAGE}|g" k8s/deployments/frontend-deployment.yaml
    else
        # Linux
        sed -i "s|YOUR_ECR_REGISTRY/wander-frontend:latest|${FRONTEND_IMAGE}|g" k8s/deployments/frontend-deployment.yaml
    fi
    echo "✅ Updated frontend-deployment.yaml"
fi

echo ""
echo "✅ ECR URLs updated successfully!"

