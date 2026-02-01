# =============================================================================
# Terraform EKS Module - Variables
# =============================================================================

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the cluster in."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs for the cluster."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the cluster."
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster."
  type        = string
}

variable "node_role_arn" {
  description = "The ARN of the IAM role for the EKS node groups."
  type        = string
}

variable "node_groups" {
  description = "A map of EKS node groups to create."
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
    desired_size  = number
    capacity_type = optional(string, "on_demand")
    labels        = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
