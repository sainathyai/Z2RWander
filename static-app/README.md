# Static App - GitOps Demo

A simple static HTML page for demonstrating GitOps workflow with Argo CD.

## 🎨 How to Change Colors

### Option 1: Use the Script

```bash
./scripts/update-color.sh "#ff6b6b"  # Red
./scripts/update-color.sh "#4ecdc4"  # Teal
./scripts/update-color.sh "#ffe66d"  # Yellow
./scripts/update-color.sh "#95e1d3"  # Mint
```

### Option 2: Manual Edit

Edit `static-app/index.html` and change the color values:

```html
<!-- In the style section -->
background: #667eea;  /* Change this color */

<!-- In the color-box style -->
background-color: #667eea;  /* Change this color */
```

## 🚀 GitOps Workflow

1. **Make a change** (e.g., update color)
2. **Commit and push** to `main` branch
3. **GitHub Actions** automatically:
   - Builds Docker image
   - Pushes to AWS ECR
   - Updates Kubernetes manifest
   - Pushes to `k8s-manifests` branch
4. **Argo CD** detects changes and deploys to EKS
5. **See your changes** live!

## 📋 Example Workflow

```bash
# 1. Change color
./scripts/update-color.sh "#ff6b6b"

# 2. Commit
git add static-app/index.html
git commit -m "chore: change color to red"

# 3. Push
git push origin main

# 4. Watch GitHub Actions workflow
# 5. Argo CD will automatically deploy
```

## 🎯 Color Suggestions

- `#ff6b6b` - Coral Red
- `#4ecdc4` - Turquoise
- `#ffe66d` - Yellow
- `#95e1d3` - Mint
- `#f38181` - Pink
- `#aa96da` - Purple
- `#fcbad3` - Light Pink
- `#a8e6cf` - Light Green

## 📝 Notes

- The app is served via nginx
- Version and build info are displayed on the page
- Health checks are configured
- The app is accessible at `/demo` path via ingress

