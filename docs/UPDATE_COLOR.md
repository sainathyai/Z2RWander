# How to Update the Color Code

## Quick Method: PowerShell Script

Use the provided PowerShell script to easily change the color:

```powershell
# Change to Green
.\scripts\update-color.ps1 "#10b981"

# Change to Red
.\scripts\update-color.ps1 "#ef4444"

# Change to Orange
.\scripts\update-color.ps1 "#f59e0b"

# Change to Purple
.\scripts\update-color.ps1 "#8b5cf6"

# Change to Pink
.\scripts\update-color.ps1 "#ec4899"

# Change to Blue
.\scripts\update-color.ps1 "#3b82f6"
```

## Manual Method

Edit `static-app/index.html` and change these lines:

1. **Line 20** - Body background:
   ```css
   background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
   ```
   Change to:
   ```css
   background: #YOUR_COLOR;
   ```

2. **Line 47** - Color box background:
   ```css
   background-color: #667eea;
   ```
   Change to:
   ```css
   background-color: #YOUR_COLOR;
   ```

## Deploy the Change

After updating the color:

```powershell
# 1. Review changes
git diff static-app/index.html

# 2. Stage the file
git add static-app/index.html

# 3. Commit
git commit -m "chore: update color to green"

# 4. Push to trigger GitOps workflow
git push origin main
```

## GitOps Workflow

Once you push, the automated workflow will:

1. ✅ **GitHub Actions** detects the commit
2. ✅ **Builds** a new Docker image with the updated color
3. ✅ **Pushes** the image to AWS ECR
4. ✅ **Updates** the Kubernetes manifest in `k8s-manifests` branch
5. ✅ **Argo CD** detects the manifest change
6. ✅ **Deploys** automatically to EKS
7. ✅ **App updates** with the new color!

## Popular Color Codes

- **Green**: `#10b981`
- **Red**: `#ef4444`
- **Orange**: `#f59e0b`
- **Purple**: `#8b5cf6`
- **Pink**: `#ec4899`
- **Blue**: `#3b82f6`
- **Teal**: `#14b8a6`
- **Yellow**: `#eab308`

## Monitor the Deployment

1. **GitHub Actions**: Check `.github/workflows/gitops-deploy.yml` status
2. **Argo CD**: Check Argo CD UI for sync status
3. **Kubernetes**: `kubectl get pods -n wander -w`
4. **App**: Refresh the LoadBalancer URL to see the new color

