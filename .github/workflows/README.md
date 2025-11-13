# GitHub Actions Workflows

## GitOps Deployment Workflow

The `gitops-deploy.yml` workflow automates the complete GitOps deployment process.

### What It Does

1. **Builds Docker Image** - Builds the static app Docker image
2. **Pushes to ECR** - Pushes image to AWS ECR with version tag
3. **Updates K8s Manifest** - Updates Kubernetes deployment manifest with new image
4. **Commits to k8s-manifests Branch** - Pushes updated manifest to trigger Argo CD sync

### Trigger

- Push to `main` branch with changes in `static-app/` directory
- Manual trigger via GitHub Actions UI

### Required Secrets

Configure these in GitHub Repository Settings → Secrets:

- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

### Workflow Steps

1. **build-and-push**
   - Checks out code
   - Configures AWS credentials
   - Logs into ECR
   - Generates version and build number
   - Builds and pushes Docker image

2. **update-k8s-manifest**
   - Checks out code and k8s-manifests branch
   - Gets AWS account ID
   - Updates Kubernetes deployment manifest
   - Commits and pushes changes

3. **notify**
   - Creates deployment summary

### Outputs

- Image tag (version-build format)
- Version number
- Build number
- Image digest

