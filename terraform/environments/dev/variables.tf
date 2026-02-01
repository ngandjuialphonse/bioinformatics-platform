# =============================================================================
# Terraform Variables - Development Environment
# =============================================================================
#
# PURPOSE:
# This file defines the input variables for the development environment.
# Variables make our Terraform code reusable and configurable.
#
# BEST PRACTICE:
# Use separate variable files for each environment (dev, prod) to manage
# different configurations (e.g., instance sizes, VPC CIDRs).
#
# =============================================================================

variable "project_name" {
  description = "The name of the project, used for tagging resources."
  type        = string
  default     = "rnaseq-pipeline"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "container_names" {
  description = "A list of container names to create ECR repositories for."
  type        = list(string)
  default = [
    "fastqc",
    "star",
    "salmon",
    "multiqc"
  ]
}
