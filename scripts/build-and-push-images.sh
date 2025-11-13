#!/bin/bash

# Script to build and push Docker images to ECR
# Usage: ./scripts/build-and-push-images.sh [backend|frontend|all]

set -e

SERVICE=${1:-all}
AWS_REGION=${AWS_REGION:-us-east-1}

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "❌ Error: Could not get AWS account ID. Make sure AWS CLI is configured."
    exit 1
fi

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

build_and_push() {
    local service=$1
    local image_name="wander-${service}"
    local ecr_repo="${ECR_REGISTRY}/${image_name}"
    
    echo "🏗️  Building ${image_name}..."
    cd "$service"
    
    # Use production Dockerfile if it exists, otherwise use dev
    if [ -f "Dockerfile" ]; then
        docker build -t "${image_name}:latest" -f Dockerfile .
    elif [ -f "Dockerfile.dev" ]; then
        docker build -t "${image_name}:latest" -f Dockerfile.dev .
    else
        echo "❌ Error: No Dockerfile found in ${service}/"
        exit 1
    fi
    
    echo "🏷️  Tagging image..."
    docker tag "${image_name}:latest" "${ecr_repo}:latest"
    
    echo "📤 Pushing to ECR..."
    docker push "${ecr_repo}:latest"
    
    cd ..
    echo "✅ Successfully pushed ${ecr_repo}:latest"
}

case "$SERVICE" in
  backend)
    build_and_push "backend"
    ;;
  frontend)
    build_and_push "frontend"
    ;;
  all)
    build_and_push "backend"
    build_and_push "frontend"
    ;;
  *)
    echo "Usage: $0 [backend|frontend|all]"
    exit 1
    ;;
esac

echo ""
echo "✅ All images pushed successfully!"
echo "📝 Update your Kubernetes manifests with ECR URLs:"
echo "   Backend:  ${ECR_REGISTRY}/wander-backend:latest"
echo "   Frontend: ${ECR_REGISTRY}/wander-frontend:latest"

