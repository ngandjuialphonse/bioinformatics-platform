# =============================================================================
# Terraform ECR Module
# =============================================================================
#
# PURPOSE:
# This module creates Amazon Elastic Container Registry (ECR) repositories.
# ECR is a fully-managed Docker container registry that makes it easy to store,
# manage, and deploy Docker container images.
#
# WHY ECR?
# - Integration with AWS: Seamlessly integrates with EKS, IAM, and other services.
# - Security: Repositories are private by default and can be scanned for vulnerabilities.
# - Scalability: Highly available and scalable container storage.
#
# =============================================================================

# -----------------------------------------------------------------------------
# ECR Repository Resource
# -----------------------------------------------------------------------------
# WHAT: Creates an ECR repository for each container name provided.
# -----------------------------------------------------------------------------
resource "aws_ecr_repository" "main" {
  for_each = toset(var.repository_names)

  name                 = "${var.project_name}-${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}
