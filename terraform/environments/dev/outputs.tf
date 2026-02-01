# =============================================================================
# Terraform Outputs - Development Environment
# =============================================================================
#
# PURPOSE:
# This file defines the output values from our Terraform configuration.
# Outputs are useful for:
# - Displaying important information to the user after `terraform apply`
# - Passing information between Terraform workspaces
# - Using in CI/CD scripts
#
# =============================================================================

output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "ecr_repository_urls" {
  description = "The URLs of the ECR repositories."
  value       = module.ecr.repository_urls
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}
