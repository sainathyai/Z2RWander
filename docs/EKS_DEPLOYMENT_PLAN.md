# EKS Deployment Plan

## 📋 Requirements Clarification

### Current PRD States:
- **System Architecture:** Kubernetes (k8s) for orchestration
- **Deployment Target:** Google Kubernetes Engine (GKE)

### Question: EKS vs GKE?

**Please clarify:**
1. Which cloud platform should we target?
   - [ ] AWS EKS (Amazon Elastic Kubernetes Service)
   - [ ] GKE (Google Kubernetes Engine) - as per PRD
   - [ ] AKS (Azure Kubernetes Service)
   - [ ] Multi-cloud (support multiple)

2. What's the deployment scope?
   - [ ] Local development only (Docker Compose) - ✅ **Current**
   - [ ] Local Kubernetes (Minikube/Kind) for testing
   - [ ] Cloud deployment (EKS/GKE) for production
   - [ ] Both local and cloud

3. What's the priority?
   - [ ] Phase 1: Local development (✅ Done)
   - [ ] Phase 2: Local Kubernetes (Optional)
   - [ ] Phase 3: Cloud deployment (EKS/GKE)

---

## 🏗️ Architecture Mapping: Docker Compose → Kubernetes

### Current Docker Compose Structure:
```yaml
services:
  postgres:    # Database
  redis:       # Cache
  backend:     # API
  frontend:    # UI
```

### Kubernetes Equivalent:

| Docker Compose | Kubernetes Resource | Purpose |
|---------------|---------------------|---------|
| `services.postgres` | `Deployment` + `Service` | PostgreSQL database |
| `services.redis` | `Deployment` + `Service` | Redis cache |
| `services.backend` | `Deployment` + `Service` | Backend API |
| `services.frontend` | `Deployment` + `Service` | Frontend UI |
| `networks` | `Service` (ClusterIP) | Internal networking |
| `volumes` | `PersistentVolumeClaim` | Data persistence |
| `environment` | `ConfigMap` / `Secret` | Configuration |
| `ports` | `Service` (NodePort/LoadBalancer) | External access |
| N/A | `Ingress` | HTTP routing |
| N/A | `Namespace` | Resource isolation |

---

## 📦 What Needs to Be Created for EKS

### 1. Kubernetes Manifests

#### Structure:
```
k8s/
├── namespace.yaml              # Namespace for the app
├── deployments/
│   ├── postgres-deployment.yaml
│   ├── redis-deployment.yaml
│   ├── backend-deployment.yaml
│   └── frontend-deployment.yaml
├── services/
│   ├── postgres-service.yaml
│   ├── redis-service.yaml
│   ├── backend-service.yaml
│   └── frontend-service.yaml
├── configmaps/
│   └── app-config.yaml         # Non-sensitive config
├── secrets/
│   └── app-secrets.yaml        # Sensitive data (DB passwords, etc.)
├── persistentvolumeclaims/
│   ├── postgres-pvc.yaml
│   └── redis-pvc.yaml
└── ingress/
    └── app-ingress.yaml        # External access
```

### 2. EKS-Specific Resources

#### AWS Resources Needed:
- **EKS Cluster** - Kubernetes cluster
- **Node Group** - EC2 instances running pods
- **IAM Roles** - For service accounts
- **VPC** - Network configuration
- **Security Groups** - Network security
- **Load Balancer** - External access (via Ingress)
- **EBS Volumes** - Persistent storage (via PVC)

### 3. Deployment Scripts

```bash
scripts/
├── deploy-eks.sh              # Deploy to EKS
├── setup-eks-cluster.sh       # Create EKS cluster
├── build-and-push-images.sh   # Build & push to ECR
└── update-k8s-config.sh       # Update kubectl config
```

### 4. CI/CD Integration

- Build Docker images
- Push to AWS ECR (Elastic Container Registry)
- Deploy to EKS using kubectl/Helm
- Environment promotion (dev → staging → prod)

---

## 🚀 EKS Deployment Steps

### Prerequisites:
1. AWS CLI configured
2. kubectl installed
3. eksctl installed (or use AWS Console)
4. Docker images built and pushed to ECR

### Step 1: Create EKS Cluster
```bash
eksctl create cluster \
  --name wander-dev \
  --region us-east-1 \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3
```

### Step 2: Configure kubectl
```bash
aws eks update-kubeconfig --name wander-dev --region us-east-1
```

### Step 3: Create Namespace
```bash
kubectl apply -f k8s/namespace.yaml
```

### Step 4: Create Secrets and ConfigMaps
```bash
kubectl apply -f k8s/secrets/
kubectl apply -f k8s/configmaps/
```

### Step 5: Create Persistent Volumes
```bash
kubectl apply -f k8s/persistentvolumeclaims/
```

### Step 6: Deploy Services
```bash
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/services/
```

### Step 7: Set Up Ingress
```bash
kubectl apply -f k8s/ingress/
```

---

## 📊 What Can Be Demonstrated for EKS

### Option 1: Show the Structure (No Cluster Needed)
- Show Kubernetes manifest files
- Explain how Docker Compose maps to K8s
- Show deployment commands
- Explain the architecture

### Option 2: Local Kubernetes (Minikube/Kind)
- Run Kubernetes locally
- Deploy the same services
- Show kubectl commands
- Demonstrate scaling

### Option 3: Actual EKS Cluster (If Available)
- Show cluster status
- Deploy services
- Show pods running
- Demonstrate service access
- Show scaling in action

---

## 🎯 Demo Scenarios for EKS

### Scenario 1: Conceptual Demo (No Cluster)
**What to Show:**
1. Docker Compose file
2. Equivalent Kubernetes manifests
3. Explain the mapping
4. Show deployment commands

**What to Say:**
- "This is how we'd deploy to EKS"
- "Same services, orchestrated by Kubernetes"
- "Production-ready, scalable architecture"

### Scenario 2: Local Kubernetes Demo
**What to Show:**
1. Start Minikube/Kind
2. Deploy services
3. Show pods running
4. Access services

**What to Say:**
- "This runs locally but uses Kubernetes"
- "Same manifests work on EKS"
- "Test production configs locally"

### Scenario 3: EKS Cluster Demo
**What to Show:**
1. EKS cluster status
2. Deploy services
3. Show running pods
4. Access via LoadBalancer/Ingress
5. Show scaling

**What to Say:**
- "This is production deployment"
- "Scalable, highly available"
- "Same code, different environment"

---

## 📝 Implementation Checklist

### Phase 1: Preparation
- [ ] Clarify requirements (EKS vs GKE)
- [ ] Set up AWS account/access
- [ ] Install eksctl/kubectl
- [ ] Create ECR repository

### Phase 2: Kubernetes Manifests
- [ ] Create namespace
- [ ] Create deployments for all services
- [ ] Create services for networking
- [ ] Create ConfigMaps for configuration
- [ ] Create Secrets for sensitive data
- [ ] Create PVCs for persistent storage
- [ ] Create Ingress for external access

### Phase 3: EKS Setup
- [ ] Create EKS cluster
- [ ] Configure kubectl
- [ ] Set up IAM roles
- [ ] Configure networking (VPC, Security Groups)
- [ ] Set up Load Balancer

### Phase 4: Deployment
- [ ] Build Docker images
- [ ] Push to ECR
- [ ] Deploy to EKS
- [ ] Verify services are running
- [ ] Test access

### Phase 5: Documentation
- [ ] EKS setup guide
- [ ] Deployment procedures
- [ ] Troubleshooting guide
- [ ] Cost optimization tips

---

## 💰 Cost Considerations

### EKS Cluster:
- **Control Plane:** ~$0.10/hour (~$73/month)
- **Node Group:** Depends on instance type
  - t3.medium: ~$0.0416/hour (~$30/month)
  - 2 nodes: ~$60/month
- **Load Balancer:** ~$0.0225/hour (~$16/month)
- **EBS Volumes:** ~$0.10/GB/month

### Estimated Monthly Cost:
- Small cluster (2 nodes): ~$150-200/month
- Medium cluster (3-4 nodes): ~$250-350/month

---

## 🔄 Next Steps

1. **Clarify Requirements:**
   - Confirm EKS vs GKE
   - Confirm timeline
   - Confirm budget

2. **If EKS is Required:**
   - Create Kubernetes manifests
   - Set up EKS cluster (or use existing)
   - Create deployment scripts
   - Document the process

3. **If EKS is Future:**
   - Document the plan
   - Create placeholder structure
   - Plan Phase 2 implementation

---

## 📚 Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [eksctl Documentation](https://eksctl.io/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

