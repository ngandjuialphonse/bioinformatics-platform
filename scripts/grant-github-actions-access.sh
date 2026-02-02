#!/bin/bash
# =============================================================================
# Grant GitHub Actions Access to EKS Cluster
# =============================================================================
#
# PURPOSE:
# This script grants the GitHub Actions IAM user access to the EKS cluster
# by updating the aws-auth ConfigMap.
#
# WHY THIS IS NEEDED:
# - The cluster creator has admin access by default
# - GitHub Actions uses a different IAM user (bioinformatic-user)
# - That user needs to be added to the cluster's RBAC
#
# USAGE:
#   bash scripts/grant-github-actions-access.sh
#
# PREREQUISITES:
# - AWS CLI configured with admin credentials
# - kubectl installed
# - EKS cluster already created
#
# =============================================================================

set -e

CLUSTER_NAME="rnaseq-pipeline-cluster"
REGION="us-east-1"
IAM_USER="bioinformatic-user"
AWS_ACCOUNT_ID="251214541935"

echo "=========================================="
echo "Grant GitHub Actions Access to EKS"
echo "=========================================="
echo ""

# Update kubeconfig
echo "📝 Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Verify current access
echo ""
echo "🔍 Verifying current cluster access..."
if kubectl cluster-info &>/dev/null; then
    echo "✅ You have cluster access"
else
    echo "❌ You don't have cluster access. Make sure you created the cluster."
    exit 1
fi

# Apply aws-auth ConfigMap
echo ""
echo "📝 Applying aws-auth ConfigMap..."
kubectl apply -f k8s/aws-auth.yaml

# Verify the ConfigMap was created
echo ""
echo "🔍 Verifying aws-auth ConfigMap..."
kubectl get configmap aws-auth -n kube-system -o yaml

echo ""
echo "=========================================="
echo "✅ Successfully granted access!"
echo "=========================================="
echo ""
echo "GitHub Actions can now deploy to the cluster."
echo "The IAM user '$IAM_USER' has been granted cluster admin access."
echo ""
