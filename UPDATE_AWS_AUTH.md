# How to Update aws-auth ConfigMap

Since kubectl can't access the cluster yet, you need to update the `aws-auth` ConfigMap first. Here are the options:

## Option 1: Use eksctl (Recommended if installed)

```bash
eksctl create iamidentitymapping \
  --cluster dev-env-cluster \
  --region us-east-1 \
  --arn arn:aws:iam::971422717446:user/sainatha.yatham@gmail.com \
  --group system:masters \
  --username admin
```

## Option 2: Use kubectl from a machine with access

If you have access to a machine that can already access the cluster:

```bash
# Get existing ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth-existing.yaml

# Edit and add your user, then apply
kubectl apply -f aws-auth-update.yaml
```

## Option 3: Use AWS Systems Manager Session Manager

If you have an EC2 instance in the cluster VPC:

```bash
# Start a session
aws ssm start-session --target <instance-id>

# Then run kubectl commands from there
```

## Option 4: Manual via AWS Console

1. Go to AWS EKS Console
2. Select your cluster
3. Go to "Access" tab
4. Add your IAM user/role

## Quick Fix Script

I've created `aws-auth-update.yaml` file. Once you have kubectl access (via any method above), run:

```bash
kubectl apply -f aws-auth-update.yaml
```

Then wait a few seconds and test:
```bash
kubectl get nodes
```

Once that works, you can deploy the static app!

