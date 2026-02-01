# =============================================================================
# Terraform ECR Module - Variables
# =============================================================================

variable "repository_names" {
  description = "A list of names for the ECR repositories to create."
  type        = list(string)
}

variable "project_name" {
  description = "The name of the project, used as a prefix for repository names."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
