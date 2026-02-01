# Learning Module 3: Infrastructure as Code (IaC) with Terraform

## The "Why": From Manual Clicks to Automated Infrastructure

In the early days of cloud computing, infrastructure was provisioned manually through web consoles. This approach is slow, error-prone, and impossible to reproduce consistently. **Infrastructure as Code (IaC)** solves this by managing infrastructure in a descriptive model, using the same versioning as DevOps teams use for source code.

> **Infrastructure as Code (IaC)** is the process of managing and provisioning computer data centers through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

For our project, we use **Terraform**, the industry-standard IaC tool, to define and create our entire AWS environment.

### Key Benefits of IaC for Bioinformatics

| Benefit | Why It Matters in Bioinformatics | How We Implemented It |
| :--- | :--- | :--- |
| **Reproducibility** | A core tenet of science. IaC guarantees that the computational environment is identical for every pipeline run, whether on a developer's laptop or in production. | Our Terraform code defines the exact versions of the EKS cluster, the instance types, and the networking, ensuring a consistent environment. |
| **Scalability & Cost Control** | Bioinformatics workloads are "bursty." IaC allows us to define autoscaling rules to provision powerful compute nodes when needed and scale them down to save costs when idle. | The `aws_eks_node_group` resource in our EKS module defines `min_size`, `max_size`, and `desired_size` for our node groups. |
| **Disaster Recovery** | If an entire AWS region were to fail, we could use our Terraform code to recreate our entire infrastructure stack in a different region in minutes. | Our modular design allows us to easily change the `aws_region` variable and redeploy. |
| **Collaboration & Version Control** | Infrastructure is now code. It can be checked into Git, reviewed in Pull Requests, and versioned, providing a complete history of all infrastructure changes. | The entire `terraform/` directory is part of our Git repository. |

---

## Our Terraform Structure: A Modular Approach

Our Terraform code is organized into a modular structure, which is a best practice for managing complex infrastructure.

**Directory:** `terraform/`

-   **`environments/dev/`**: This is the top-level configuration for our `dev` environment. It defines which modules to use and what variable values to pass to them.
-   **`modules/`**: This directory contains our reusable infrastructure modules (vpc, eks, iam, ecr). Each module is a self-contained package of Terraform configurations that manages a specific piece of our infrastructure.

### The `main.tf` Entrypoint

**File:** `environments/dev/main.tf`

This file orchestrates the creation of our entire environment by calling the modules.

```hcl
module "vpc" {
  source = "../../modules/vpc"
  # ... variables ...
}

module "eks" {
  source = "../../modules/eks"
  # ... variables ...
}
```

This declarative syntax is the core of Terraform. You declare the desired state of your infrastructure, and Terraform figures out how to make it happen.

### Remote State Management

A critical component of our setup is the **remote backend**.

```hcl
backend "s3" {
  bucket         = "rnaseq-pipeline-tfstate-bucket"
  key            = "dev/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-lock-table"
}
```

-   **What is State?** Terraform keeps a `terraform.tfstate` file to map the resources in your code to the real-world resources in AWS. By default, this is stored locally.
-   **Why Remote?** Storing the state file in an S3 bucket allows multiple team members (and our CI/CD pipeline) to work on the same infrastructure without conflicts.
-   **State Locking:** The `dynamodb_table` provides **state locking**. If one person is running `terraform apply`, the state is "locked," preventing anyone else from making concurrent changes that could corrupt the state.

> **Interview Talking Point:** Explain that you use a remote S3 backend with DynamoDB for state locking. This demonstrates that you understand how to use Terraform in a professional, collaborative team environment.

### Module Example: EKS Node Groups

Let's look at how we define our EKS worker nodes in `modules/eks/main.tf`.

```hcl
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  // ... configuration ...

  instance_types = [each.value.instance_type]
  capacity_type  = each.value.capacity_type == "spot" ? "SPOT" : "ON_DEMAND"

  scaling_config {
    min_size     = each.value.min_size
    max_size     = each.value.max_size
    desired_size = each.value.desired_size
  }
}
```

This is a powerful example of IaC. We use a `for_each` loop to create multiple node groups from a map variable. This allows us to have different types of worker nodes for different tasks:

-   A `general` node group with smaller, on-demand instances for general-purpose tasks.
-   A `high_mem` node group with large, memory-optimized **spot instances** for the STAR alignment step, which is memory-intensive. Using spot instances can reduce compute costs by up to 90%.

---

## Summary & Interview Talking Points

-   **You treat infrastructure as code.** This is the fundamental principle of DevOps and is essential for reproducible science and scalable platforms.
-   **You can explain the benefits of a modular Terraform structure.** It's reusable, maintainable, and follows best practices.
-   **You understand professional Terraform practices like remote state and state locking.** This is a key differentiator from hobbyist-level IaC.
-   **You can describe how you use IaC to optimize for both cost and performance.** You use spot instances for expensive, interruptible workloads and on-demand instances for baseline tasks.
-   **You can connect IaC directly to the needs of bioinformatics.** Reproducible environments lead to reproducible results. Scalable infrastructure handles large datasets and patient cohorts. Automated provisioning speeds up research and development.
