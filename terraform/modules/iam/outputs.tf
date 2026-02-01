# =============================================================================
# Terraform IAM Module - Outputs
# =============================================================================

output "eks_cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster."
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_group_role_arn" {
  description = "The ARN of the IAM role for the EKS node groups."
  value       = aws_iam_role.eks_node_group.arn
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions."
  value       = aws_iam_role.github_actions.arn
}
