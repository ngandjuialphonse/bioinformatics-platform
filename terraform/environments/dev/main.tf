# =============================================================================
# Terraform Main Configuration - Development Environment
# =============================================================================
#
# PURPOSE:
# This file is the entrypoint for provisioning the complete AWS infrastructure
# for the development environment using Terraform. It demonstrates Infrastructure
# as Code (IaC), a core DevOps practice.
#
# WHAT IS TERRAFORM?
# Terraform is an open-source IaC tool that allows you to define and provision
# infrastructure using a declarative configuration language. It treats your
# infrastructure like software - versioned, repeatable, and automated.
#
# WHY TERRAFORM FOR BIOINFORMATICS?
# 1. Reproducibility: Ensures consistent environments for pipeline execution
# 2. Scalability: Easily scale up/down compute resources as needed
# 3. Cost Management: Define resource limits and track costs
# 4. Automation: Integrate infrastructure provisioning into CI/CD pipelines
#
# INTERVIEW TIP:
# Be prepared to explain why IaC is critical for production bioinformatics.
# It shows you think about the entire lifecycle, not just the pipeline code.
#
# =============================================================================

# -----------------------------------------------------------------------------
# Terraform and Provider Configuration
# -----------------------------------------------------------------------------
# WHAT: Specifies the required Terraform version and cloud provider (AWS)
# WHY: Ensures compatibility and defines where resources will be created
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ---------------------------------------------------------------------------
  # Backend Configuration
  # ---------------------------------------------------------------------------
  # WHAT: Configures where Terraform stores its state file
  # WHY: The state file tracks the resources Terraform manages. Storing it
  # remotely (e.g., in S3) is essential for team collaboration and CI/CD.
  #
  # BEST PRACTICE: Use a remote backend like S3 with state locking (DynamoDB)
  # to prevent concurrent modifications and state corruption.
  # ---------------------------------------------------------------------------
  backend "s3" {
    bucket         = "rnaseq-pipeline-tfstate-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------
# WHAT: Configures the AWS provider with the target region
# -----------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}

# =============================================================================
# RESOURCE MODULES
# =============================================================================
# We use a modular approach to organize our infrastructure code. Each module
# is a self-contained unit responsible for a specific part of the infrastructure.
#
# WHY MODULES?
# - Reusability: Use the same module for dev, prod, etc.
# - Maintainability: Easier to understand and manage smaller pieces
# - Abstraction: Hides complexity within the module
#
# =============================================================================

# -----------------------------------------------------------------------------
# Module 1: Virtual Private Cloud (VPC)
# -----------------------------------------------------------------------------
# WHAT: Creates an isolated network environment in AWS for our resources
# WHY: Security and network control. It's like having your own private data center.
# -----------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  vpc_name            = "${var.project_name}-vpc"
  vpc_cidr_block      = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  availability_zones  = ["${var.aws_region}a", "${var.aws_region}b"]

  tags = {
    Project     = var.project_name
    Environment = "dev"
  }
}

# -----------------------------------------------------------------------------
# Module 2: Elastic Container Registry (ECR)
# -----------------------------------------------------------------------------
# WHAT: Creates private Docker container registries
# WHY: Securely store the custom Docker images our pipeline uses
# -----------------------------------------------------------------------------
module "ecr" {
  source = "../../modules/ecr"

  repository_names = var.container_names
  project_name     = var.project_name

  tags = {
    Project     = var.project_name
    Environment = "dev"
  }
}

# -----------------------------------------------------------------------------
# Module 3: Identity and Access Management (IAM)
# -----------------------------------------------------------------------------
# WHAT: Creates the necessary roles and policies for EKS and Nextflow
# WHY: Security. We grant only the minimum permissions required for each component.
# -----------------------------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  project_name      = var.project_name
  aws_account_id    = data.aws_caller_identity.current.account_id
  oidc_provider_arn = module.eks.oidc_provider_arn

  tags = {
    Project     = var.project_name
    Environment = "dev"
  }
}

# -----------------------------------------------------------------------------
# Module 4: Elastic Kubernetes Service (EKS)
# -----------------------------------------------------------------------------
# WHAT: Creates a managed Kubernetes cluster
# WHY: EKS handles the complexity of running a Kubernetes control plane,
# allowing us to focus on deploying and running our pipeline.
# -----------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  cluster_name    = "${var.project_name}-cluster"
  vpc_id          = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_group_role_arn

  node_groups = {
    general = {
      instance_type = "t3.medium"
      min_size      = 1
      max_size      = 3
      desired_size  = 2
    }
    high_mem = {
      instance_type = "r5.2xlarge"
      min_size      = 0
      max_size      = 5
      desired_size  = 1
      labels        = { "node-type" = "high-memory" }
      taints = [
        {
          key    = "workload-type"
          value  = "high-memory"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  tags = {
    Project     = var.project_name
    Environment = "dev"
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
# WHAT: Fetches information from AWS that we need for our configuration
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
