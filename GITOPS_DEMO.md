# GitOps Demo Guide

This guide explains how to use the GitOps workflow to deploy the static app with automatic deployments.

## 🎯 What is This?

A simple static HTML page that demonstrates GitOps workflow:
- **Make a change** (e.g., change color)
- **Commit and push** to GitHub
- **GitHub Actions** automatically builds and pushes to ECR
- **Argo CD** automatically deploys to EKS
- **See changes live** in minutes!

## 🚀 Quick Start

### 1. Prerequisites

- AWS CLI configured
- EKS cluster deployed (see `README_EKS.md`)
- Argo CD installed and configured
- GitHub repository with Actions enabled
- GitHub Secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `GITHUB_TOKEN` (automatically available)

### 2. Initial Setup

```bash
# 1. Deploy EKS infrastructure (if not done)
cd terraform
terraform init
terraform apply

# 2. Configure kubectl
terraform output configure_kubectl
# Run the output command

# 3. Install Argo CD (if not done)
./scripts/install-argocd.sh

# 4. Push manifests to k8s-manifests branch
./scripts/push-manifests-to-branch.sh

# 5. Update Argo CD application with your repo URL
# Edit argocd/applications/wander-app.yaml
kubectl apply -f argocd/applications/wander-app.yaml
```

### 3. Make Your First Change

```bash
# Change the color
./scripts/update-color.sh "#ff6b6b"

# Commit and push
git add static-app/index.html
git commit -m "chore: change color to red"
git push origin main
```

### 4. Watch the Magic Happen

1. **GitHub Actions** will automatically:
   - Build Docker image
   - Push to ECR
   - Update Kubernetes manifest
   - Push to `k8s-manifests` branch

2. **Argo CD** will automatically:
   - Detect changes in `k8s-manifests` branch
   - Sync deployment to EKS
   - Roll out new version

3. **Check your deployment**:
   ```bash
   # Watch pods
   kubectl get pods -n wander -w
   
   # Check Argo CD sync status
   kubectl get application -n argocd
   ```

## 🎨 Changing Colors

### Using the Script

```bash
./scripts/update-color.sh "#4ecdc4"  # Teal
./scripts/update-color.sh "#ffe66d"  # Yellow
./scripts/update-color.sh "#95e1d3"  # Mint
```

### Manual Edit

Edit `static-app/index.html`:

```html
<!-- Change this -->
background: #667eea;

<!-- To this -->
background: #ff6b6b;
```

Then commit and push!

## 📊 Workflow Diagram

```
┌─────────────┐
│   GitHub    │
│   Commit    │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ GitHub Actions  │
│ 1. Build Image  │
│ 2. Push to ECR  │
│ 3. Update K8s   │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ k8s-manifests   │
│     Branch      │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│    Argo CD      │
│  Auto Sync      │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│      EKS        │
│   Deployment    │
└─────────────────┘
```

## 🔍 Monitoring

### GitHub Actions

View workflow runs:
- Go to your GitHub repository
- Click "Actions" tab
- See workflow status and logs

### Argo CD

Access Argo CD UI:
```bash
# Get Argo CD server URL
kubectl get svc argocd-server -n argocd

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Kubernetes

```bash
# Check pods
kubectl get pods -n wander -l app=static-app

# Check deployment
kubectl get deployment static-app-deployment -n wander

# View logs
kubectl logs -n wander -l app=static-app --tail=50

# Check service
kubectl get svc static-app-service -n wander
```

## 🎯 Demo Scenarios

### Scenario 1: Color Change

1. Change color to red: `./scripts/update-color.sh "#ff6b6b"`
2. Commit and push
3. Watch GitHub Actions workflow
4. See Argo CD sync
5. Verify new color in browser

### Scenario 2: Multiple Changes

1. Make several color changes
2. Each commit triggers a new deployment
3. Watch version numbers increment
4. See deployment history in Argo CD

### Scenario 3: Rollback

1. If something goes wrong, use Argo CD UI to rollback
2. Or manually update the manifest in `k8s-manifests` branch

## 🔧 Troubleshooting

### GitHub Actions Fails

- Check AWS credentials in GitHub Secrets
- Verify ECR repository exists
- Check workflow logs for errors

### Argo CD Not Syncing

- Check Argo CD application status: `kubectl get application -n argocd`
- Verify repository URL is correct
- Check Argo CD logs: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server`

### Image Not Updating

- Verify image tag in deployment: `kubectl describe deployment static-app-deployment -n wander`
- Check ECR for new images
- Verify manifest was updated in `k8s-manifests` branch

### Pods Not Starting

- Check pod status: `kubectl get pods -n wander`
- View pod logs: `kubectl logs <pod-name> -n wander`
- Check events: `kubectl describe pod <pod-name> -n wander`

## 📝 Best Practices

1. **Always test locally** before pushing
2. **Use meaningful commit messages**
3. **Monitor GitHub Actions** for build status
4. **Check Argo CD** for sync status
5. **Verify deployment** after changes

## 🎉 Success!

You now have a fully automated GitOps workflow:
- ✅ Code changes trigger builds
- ✅ Images automatically pushed to ECR
- ✅ Kubernetes manifests automatically updated
- ✅ Argo CD automatically deploys
- ✅ Zero manual intervention!

## 📚 Additional Resources

- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

