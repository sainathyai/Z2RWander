# How to Access the Static App

The static app is deployed on EKS. Here are different ways to access it:

## Option 1: Port-Forward (Recommended for Testing)

**Best for:** Local development and testing

```bash
kubectl port-forward -n wander svc/static-app-service 8080:80
```

Then open in your browser: **http://localhost:8080**

**To stop:** Press `Ctrl+C` in the terminal

---

## Option 2: LoadBalancer Service (Public Access)

**Best for:** Quick public access without domain setup

### Create LoadBalancer Service:

```bash
kubectl apply -f k8s/services/static-app-service-lb.yaml
```

### Get the External IP:

```bash
kubectl get svc -n wander static-app-service-lb
```

Wait for `EXTERNAL-IP` to be assigned (may take 1-2 minutes), then access:
- **http://<EXTERNAL-IP>**

**Note:** This creates an AWS Load Balancer and incurs costs (~$16/month)

---

## Option 3: Ingress with ALB (Production)

**Best for:** Production with custom domain

### Prerequisites:
1. AWS Load Balancer Controller installed
2. Domain name configured
3. SSL certificate (optional but recommended)

### Setup:

1. **Install AWS Load Balancer Controller** (if not installed):
   ```bash
   # Check if installed
   kubectl get deployment -n kube-system aws-load-balancer-controller
   
   # If not, install it (see AWS documentation)
   ```

2. **Update Ingress** with your domain:
   ```bash
   # Edit k8s/ingress/app-ingress.yaml
   # Change: host: wander.example.com
   # To: host: your-domain.com
   ```

3. **Apply Ingress**:
   ```bash
   kubectl apply -f k8s/ingress/app-ingress.yaml
   ```

4. **Get Ingress Address**:
   ```bash
   kubectl get ingress -n wander
   ```

5. **Access via**:
   - **http://your-domain.com/demo** (or the ALB address)

---

## Option 4: NodePort (Alternative)

**Best for:** Direct node access (not recommended for production)

```bash
# Change service type to NodePort
kubectl patch svc static-app-service -n wander -p '{"spec":{"type":"NodePort"}}'

# Get node IP and port
kubectl get nodes -o wide
kubectl get svc -n wander static-app-service

# Access: http://<NODE-IP>:<NODE-PORT>
```

---

## Quick Start (Port-Forward)

**Easiest way to test right now:**

```bash
# Start port-forward
kubectl port-forward -n wander svc/static-app-service 8080:80

# Open browser
# http://localhost:8080
```

---

## Verify App is Running

```bash
# Check pods
kubectl get pods -n wander

# Check service
kubectl get svc -n wander

# Check logs
kubectl logs -n wander -l app=static-app --tail=20
```

---

## Troubleshooting

### Port-forward not working?
```bash
# Check if service exists
kubectl get svc -n wander

# Check if pods are running
kubectl get pods -n wander

# Try different port
kubectl port-forward -n wander svc/static-app-service 3000:80
```

### LoadBalancer stuck in Pending?
- Check AWS Load Balancer Controller is installed
- Check IAM permissions
- Check security groups

### Can't access via Ingress?
- Verify AWS Load Balancer Controller is running
- Check ingress status: `kubectl describe ingress -n wander`
- Check ALB in AWS Console

---

## Current Setup

- **Service Type:** ClusterIP (internal only)
- **Namespace:** wander
- **Port:** 80
- **Access:** Use port-forward or create LoadBalancer/Ingress

