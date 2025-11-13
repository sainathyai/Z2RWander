# Deployment Status

## ✅ Completed Steps

1. ✅ **ECR Repository Created**
   - Repository: `wander-static-app`
   - URL: `971422717446.dkr.ecr.us-east-1.amazonaws.com/wander-static-app`

2. ✅ **Docker Image Built**
   - Image: `wander-static-app:latest`
   - Successfully built from `static-app/Dockerfile`

3. ✅ **Image Pushed to ECR**
   - Tags: `latest` and `v1.0.0`
   - Digest: `sha256:976803a7ba63ea68da36d5147b06af572f61942fe8d1fc47921fbce18b0b37aa`

4. ✅ **Kubernetes Manifest Updated**
   - Updated `k8s/deployments/static-app-deployment.yaml` with correct ECR URL

## ⚠️ Pending: kubectl Access

**Issue**: kubectl cannot access the EKS cluster due to missing permissions in `aws-auth` ConfigMap.

**Solution Options**:

### Option 1: Add User to aws-auth (Requires Cluster Admin)

If you have cluster admin access, run:

```bash
# Get your user ARN
USER_ARN=$(aws sts get-caller-identity --query Arn --output text)

# Create aws-auth update
cat <<EOF | kubectl apply -f -
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
EOF
```

### Option 2: Use IAM Role (If Available)

If you have an IAM role with cluster access:

```bash
aws eks update-kubeconfig --region us-east-1 --name dev-env-cluster --role-arn <role-arn>
```

### Option 3: Ask Cluster Admin

Ask your cluster administrator to add this user to the `aws-auth` ConfigMap:

- **User ARN**: `arn:aws:iam::971422717446:user/sainatha.yatham@gmail.com`
- **Username**: `admin`
- **Groups**: `system:masters`

## 🚀 Once kubectl Access is Fixed

Run these commands to deploy:

```bash
# 1. Create namespace
kubectl create namespace wander

# 2. Apply manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/services/static-app-service.yaml
kubectl apply -f k8s/deployments/static-app-deployment.yaml

# 3. Check deployment status
kubectl get pods -n wander
kubectl get svc -n wander

# 4. Check logs
kubectl logs -n wander -l app=static-app
```

## 📋 Quick Deploy Script

Once kubectl access is working, you can use:

```bash
# Deploy everything
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/services/static-app-service.yaml
kubectl apply -f k8s/deployments/static-app-deployment.yaml

# Watch deployment
kubectl get pods -n wander -w

# Get service URL (if using LoadBalancer or Ingress)
kubectl get svc -n wander
```

## 🔍 Verify Deployment

```bash
# Check pods
kubectl get pods -n wander -l app=static-app

# Check service
kubectl get svc static-app-service -n wander

# Port forward to test locally
kubectl port-forward -n wander svc/static-app-service 8080:80

# Then open: http://localhost:8080
```

## 📝 Next Steps

1. Fix kubectl access (see options above)
2. Deploy to EKS (commands above)
3. Set up Ingress or LoadBalancer for external access
4. Configure Argo CD for GitOps (optional)

