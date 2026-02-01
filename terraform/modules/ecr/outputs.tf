# =============================================================================
# Terraform ECR Module - Outputs
# =============================================================================

output "repository_urls" {
  description = "A map of repository names to their URLs."
  value       = { for name, repo in aws_ecr_repository.main : name => repo.repository_url }
}
