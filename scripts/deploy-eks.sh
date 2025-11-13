#!/bin/bash

# Script to deploy EKS infrastructure using Terraform
# Usage: ./scripts/deploy-eks.sh [init|plan|apply|destroy]

set -e

TERRAFORM_DIR="terraform"
ACTION=${1:-apply}

cd "$TERRAFORM_DIR"

case "$ACTION" in
  init)
    echo "🔧 Initializing Terraform..."
    terraform init
    ;;
  plan)
    echo "📋 Planning Terraform changes..."
    terraform plan -out=tfplan
    ;;
  apply)
    echo "🚀 Applying Terraform configuration..."
    if [ -f "tfplan" ]; then
      terraform apply tfplan
      rm -f tfplan
    else
      terraform apply
    fi
    
    echo "✅ EKS cluster created successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Configure kubectl:"
    terraform output -raw configure_kubectl
    echo ""
    echo "2. Login to ECR:"
    terraform output -raw ecr_login_command
    echo ""
    echo "3. Build and push Docker images (see scripts/build-and-push-images.sh)"
    echo "4. Install Argo CD (see scripts/install-argocd.sh)"
    echo "5. Push manifests to branch (see scripts/push-manifests-to-branch.sh)"
    ;;
  destroy)
    echo "⚠️  Destroying EKS infrastructure..."
    read -p "Are you sure you want to destroy all resources? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
      terraform destroy
      echo "✅ EKS cluster destroyed"
    else
      echo "❌ Destruction cancelled"
    fi
    ;;
  output)
    echo "📊 Terraform outputs:"
    terraform output
    ;;
  *)
    echo "Usage: $0 [init|plan|apply|destroy|output]"
    echo ""
    echo "Commands:"
    echo "  init    - Initialize Terraform"
    echo "  plan    - Plan Terraform changes"
    echo "  apply   - Apply Terraform configuration (default)"
    echo "  destroy - Destroy all resources"
    echo "  output  - Show Terraform outputs"
    exit 1
    ;;
esac

