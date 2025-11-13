#!/bin/bash
# Update aws-auth ConfigMap using AWS CLI
# This script needs to be run from a machine that already has kubectl access
# OR you can use AWS Systems Manager Session Manager to run it on an EC2 instance in the cluster

CLUSTER_NAME="dev-env-cluster"
REGION="us-east-1"
USER_ARN="arn:aws:iam::971422717446:user/sainatha.yatham@gmail.com"

echo "🔧 Updating aws-auth ConfigMap for cluster: $CLUSTER_NAME"

# Get existing ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml > /tmp/aws-auth-existing.yaml

# Check if user already exists
if grep -q "$USER_ARN" /tmp/aws-auth-existing.yaml; then
    echo "✅ User already exists in aws-auth"
    exit 0
fi

# Add user to ConfigMap
cat >> /tmp/aws-auth-update.yaml <<EOF
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

# If existing ConfigMap has mapUsers, we need to merge
if grep -q "mapUsers:" /tmp/aws-auth-existing.yaml; then
    # Extract existing mapUsers and append new user
    # This is a simplified version - you may need to manually edit
    echo "⚠️  Existing mapUsers found. Please manually merge or use eksctl:"
    echo "eksctl create iamidentitymapping --cluster $CLUSTER_NAME --region $REGION --arn $USER_ARN --group system:masters --username admin"
else
    kubectl apply -f /tmp/aws-auth-update.yaml
    echo "✅ Successfully updated aws-auth ConfigMap!"
fi

