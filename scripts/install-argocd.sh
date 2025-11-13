#!/bin/bash

# Script to install Argo CD on EKS cluster
# Usage: ./scripts/install-argocd.sh

set -e

ARGOCD_NAMESPACE="argocd"

echo "🔍 Checking kubectl connection..."
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ Error: kubectl is not configured or cluster is not accessible"
    echo "   Run: aws eks update-kubeconfig --region <region> --name <cluster-name>"
    exit 1
fi

echo "📦 Installing Argo CD..."

# Create namespace if it doesn't exist
kubectl create namespace $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Install Argo CD using Helm
if ! command -v helm &> /dev/null; then
    echo "❌ Error: Helm is not installed"
    echo "   Install Helm: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Add Argo CD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install Argo CD
helm upgrade --install argocd argo/argo-cd \
  --namespace $ARGOCD_NAMESPACE \
  --set configs.params.server.insecure=true \
  --set server.service.type=LoadBalancer \
  --wait

echo "⏳ Waiting for Argo CD server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n $ARGOCD_NAMESPACE

# Get Argo CD server URL
ARGOCD_SERVER=$(kubectl get svc argocd-server -n $ARGOCD_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$ARGOCD_SERVER" ]; then
    ARGOCD_SERVER=$(kubectl get svc argocd-server -n $ARGOCD_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
fi

# Get initial admin password
ARGOCD_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✅ Argo CD installed successfully!"
echo ""
echo "📝 Access Information:"
echo "   URL:      http://${ARGOCD_SERVER}"
echo "   Username: admin"
echo "   Password: ${ARGOCD_PASSWORD}"
echo ""
echo "🔐 To login via CLI:"
echo "   argocd login ${ARGOCD_SERVER} --username admin --password ${ARGOCD_PASSWORD} --insecure"
echo ""
echo "📋 Next steps:"
echo "1. Update argocd/applications/wander-app.yaml with your repository URL"
echo "2. Push manifests to branch: ./scripts/push-manifests-to-branch.sh"
echo "3. Apply Argo CD application: kubectl apply -f argocd/applications/wander-app.yaml"

