#!/bin/bash

# Complete EKS setup script
# This script orchestrates the entire EKS deployment process
# Usage: ./scripts/setup-eks-complete.sh

set -e

echo "🚀 Starting complete EKS setup process..."
echo ""

# Step 1: Deploy infrastructure with Terraform
echo "📦 Step 1: Deploying EKS infrastructure with Terraform..."
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ..

# Step 2: Configure kubectl
echo ""
echo "⚙️  Step 2: Configuring kubectl..."
cd terraform
KUBECTL_CMD=$(terraform output -raw configure_kubectl)
eval $KUBECTL_CMD
cd ..

# Step 3: Update ECR URLs in manifests
echo ""
echo "🔄 Step 3: Updating ECR URLs in Kubernetes manifests..."
./scripts/update-ecr-urls.sh

# Step 4: Build and push Docker images
echo ""
echo "🏗️  Step 4: Building and pushing Docker images to ECR..."
ECR_LOGIN_CMD=$(cd terraform && terraform output -raw ecr_login_command)
eval $ECR_LOGIN_CMD
./scripts/build-and-push-images.sh all

# Step 5: Install Argo CD
echo ""
echo "📦 Step 5: Installing Argo CD..."
./scripts/install-argocd.sh

# Step 6: Push manifests to branch
echo ""
echo "📤 Step 6: Pushing manifests to k8s-manifests branch..."
./scripts/push-manifests-to-branch.sh

# Step 7: Update Argo CD application with repository URL
echo ""
echo "📝 Step 7: Please update argocd/applications/wander-app.yaml with your repository URL"
echo "   Then apply: kubectl apply -f argocd/applications/wander-app.yaml"

echo ""
echo "✅ EKS setup complete!"
echo ""
echo "📋 Summary:"
echo "   - EKS cluster created"
echo "   - Docker images pushed to ECR"
echo "   - Argo CD installed"
echo "   - Manifests pushed to k8s-manifests branch"
echo ""
echo "🔗 Next steps:"
echo "   1. Update repository URL in argocd/applications/wander-app.yaml"
echo "   2. Apply Argo CD application: kubectl apply -f argocd/applications/wander-app.yaml"
echo "   3. Access Argo CD UI and verify sync"

