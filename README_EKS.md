# EKS Deployment Guide

This guide explains how to deploy the Wander application to Amazon EKS using Terraform and Argo CD.

## 📋 Prerequisites

1. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```

2. **Terraform** >= 1.0
   ```bash
   terraform version
   ```

3. **kubectl** installed
   ```bash
   kubectl version --client
   ```

4. **Helm** installed (for Argo CD)
   ```bash
   helm version
   ```

5. **Docker** installed and running
   ```bash
   docker --version
   ```

6. **Git** repository access

## 🏗️ Architecture

- **Terraform**: Creates EKS cluster, VPC, ECR repositories
- **Kubernetes Manifests**: Application deployments, services, configs
- **Argo CD**: GitOps-based continuous deployment
- **ECR**: Container image registry

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

Run the complete setup script:

```bash
chmod +x scripts/setup-eks-complete.sh
./scripts/setup-eks-complete.sh
```

This will:
1. Deploy EKS infrastructure with Terraform
2. Configure kubectl
3. Update ECR URLs in manifests
4. Build and push Docker images
5. Install Argo CD
6. Push manifests to `k8s-manifests` branch

### Option 2: Manual Setup

#### Step 1: Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

#### Step 2: Deploy Infrastructure

```bash
./scripts/deploy-eks.sh init
./scripts/deploy-eks.sh plan
./scripts/deploy-eks.sh apply
```

#### Step 3: Configure kubectl

```bash
cd terraform
terraform output configure_kubectl
# Run the output command
```

#### Step 4: Update ECR URLs

```bash
./scripts/update-ecr-urls.sh
```

#### Step 5: Build and Push Images

```bash
# Login to ECR
cd terraform
terraform output ecr_login_command
# Run the output command

# Build and push
./scripts/build-and-push-images.sh all
```

#### Step 6: Install Argo CD

```bash
./scripts/install-argocd.sh
```

#### Step 7: Push Manifests to Branch

```bash
./scripts/push-manifests-to-branch.sh
```

#### Step 8: Configure Argo CD Application

1. Update `argocd/applications/wander-app.yaml` with your repository URL
2. Apply the application:

```bash
kubectl apply -f argocd/applications/wander-app.yaml
```

## 📁 Project Structure

```
.
├── terraform/              # Terraform infrastructure code
│   ├── main.tf            # Main Terraform configuration
│   ├── variables.tf       # Variable definitions
│   ├── outputs.tf         # Output values
│   └── modules/           # Terraform modules
│       ├── vpc/           # VPC module
│       └── eks/           # EKS module
├── k8s/                   # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployments/       # Deployment manifests
│   ├── services/          # Service manifests
│   ├── configmaps/        # ConfigMap manifests
│   ├── secrets/           # Secret manifests
│   ├── persistentvolumeclaims/  # PVC manifests
│   └── ingress/           # Ingress manifests
├── argocd/                # Argo CD configurations
│   └── applications/      # Argo CD application manifests
└── scripts/               # Deployment scripts
    ├── deploy-eks.sh
    ├── build-and-push-images.sh
    ├── install-argocd.sh
    ├── push-manifests-to-branch.sh
    └── setup-eks-complete.sh
```

## 🔧 Configuration

### Terraform Variables

Edit `terraform/terraform.tfvars`:

```hcl
aws_region         = "us-east-1"
environment        = "dev"
cluster_name       = "wander-cluster"
kubernetes_version = "1.28"
vpc_cidr           = "10.0.0.0/16"
```

### Kubernetes Manifests

Update image URLs in:
- `k8s/deployments/backend-deployment.yaml`
- `k8s/deployments/frontend-deployment.yaml`

Or run `./scripts/update-ecr-urls.sh` to auto-update.

### Argo CD Application

Update `argocd/applications/wander-app.yaml`:

```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/Z2RWander.git
  targetRevision: k8s-manifests
```

## 🔍 Verification

### Check EKS Cluster

```bash
kubectl cluster-info
kubectl get nodes
```

### Check Pods

```bash
kubectl get pods -n wander
```

### Check Services

```bash
kubectl get svc -n wander
```

### Check Argo CD

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

## 🔄 GitOps Workflow

1. **Make changes** to Kubernetes manifests in `k8s/` directory
2. **Push to branch**: `./scripts/push-manifests-to-branch.sh`
3. **Argo CD syncs** automatically (if auto-sync enabled)
4. **Or manually sync** via Argo CD UI or CLI

## 🧹 Cleanup

### Destroy Infrastructure

```bash
cd terraform
terraform destroy
```

### Delete Argo CD

```bash
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```

## 📚 Additional Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🐛 Troubleshooting

### kubectl not configured

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

### ECR login failed

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
```

### Argo CD sync failed

Check application status:
```bash
kubectl get application -n argocd
kubectl describe application wander-app -n argocd
```

### Pods not starting

Check pod logs:
```bash
kubectl logs <pod-name> -n wander
kubectl describe pod <pod-name> -n wander
```

## 💰 Cost Estimation

- **EKS Control Plane**: ~$73/month
- **Node Group** (2x t3.medium): ~$60/month
- **Load Balancer**: ~$16/month
- **EBS Volumes**: ~$3/month
- **Total**: ~$150-200/month

## 🔐 Security Notes

1. **Secrets**: Update `k8s/secrets/app-secrets.yaml` with secure values
2. **Use AWS Secrets Manager** for production
3. **Restrict EKS API access** in production
4. **Enable encryption** for EBS volumes
5. **Use IAM roles** for service accounts

## 📝 Next Steps

1. Set up CI/CD pipeline for automated builds
2. Configure monitoring and logging
3. Set up backup strategies
4. Implement blue-green deployments
5. Configure autoscaling policies

