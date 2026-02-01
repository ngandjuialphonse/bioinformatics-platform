# =============================================================================
# Terraform EKS Module
# =============================================================================
#
# PURPOSE:
# This module creates an Amazon Elastic Kubernetes Service (EKS) cluster.
# EKS is a managed Kubernetes service that simplifies running Kubernetes on AWS.
#
# WHY EKS FOR BIOINFORMATICS:
# - Scalability: Easily scale your compute nodes based on pipeline demand.
# - Cost-Effectiveness: Use Spot Instances for significant cost savings on compute.
# - Portability: Kubernetes is the industry standard for container orchestration.
# - Integration: Tightly integrated with other AWS services like ECR, EFS, and IAM.
#
# =============================================================================

# -----------------------------------------------------------------------------
# EKS Cluster Resource
# -----------------------------------------------------------------------------
# WHAT: The main EKS cluster resource.
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# -----------------------------------------------------------------------------
# EKS Node Groups
# -----------------------------------------------------------------------------
# WHAT: The worker nodes (EC2 instances) where your pipeline tasks will run.
# WHY MULTIPLE NODE GROUPS:
# - Cost Optimization: Use cheaper, general-purpose instances for most tasks.
# - Performance: Use memory-optimized instances for resource-intensive tasks
#   like STAR alignment.
# -----------------------------------------------------------------------------
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = [each.value.instance_type]
  capacity_type  = each.value.capacity_type == "spot" ? "SPOT" : "ON_DEMAND"

  scaling_config {
    min_size     = each.value.min_size
    max_size     = each.value.max_size
    desired_size = each.value.desired_size
  }

  labels = each.value.labels
  taints = each.value.taints

  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-${each.key}-node"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only_policy
  ]
}

# -----------------------------------------------------------------------------
# OIDC Provider for GitHub Actions
# -----------------------------------------------------------------------------
# WHAT: Creates an OIDC identity provider for the EKS cluster.
# WHY: Allows GitHub Actions to securely authenticate with Kubernetes.
# -----------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "main" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
