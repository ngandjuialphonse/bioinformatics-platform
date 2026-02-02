# =============================================================================
# Terraform IAM Module - Variables
# =============================================================================

variable "project_name" {
  description = "The name of the project, used for naming IAM resources."
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID."
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for GitHub Actions."
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository in the format owner/repo."
  type        = string
}

variable "aws_region" {
  description = "The AWS region."
  type        = string
}

variable "reports_bucket_arn" {
  description = "The ARN of the S3 bucket for pipeline reports."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
