# Enterprise-Grade RNA-Seq Pipeline Platform

This repository represents a production-ready, enterprise-grade bioinformatics platform for running RNA-Seq analysis at scale. It is designed to be a portfolio project that demonstrates mastery of the key skills required for senior bioinformatics engineering roles, including Nextflow, Kubernetes, AWS, Terraform, Docker, and automated testing.

This is not just a pipeline; it is a complete **platform** that includes:

-   A scientifically validated RNA-Seq pipeline written in Nextflow DSL2.
-   A comprehensive, multi-layered automated testing suite using `nf-test`.
-   A full CI/CD workflow in GitHub Actions for automated building, testing, and deployment.
-   Infrastructure as Code (IaC) using Terraform to provision a production EKS cluster.
-   Optimized, secure, multi-stage Docker containers for all pipeline tools.
-   A complete set of learning documentation explaining the "why" behind the engineering decisions.

## Core Concepts Demonstrated

This project is designed to be a talking point in a technical interview. It demonstrates a deep understanding of the following core concepts:

| Concept | Implementation | Why it Matters |
| :--- | :--- | :--- |
| **Reproducibility** | Pinned software versions, containerization, and IaC ensure that the same inputs will always produce the same outputs. | The cornerstone of valid science and a requirement for clinical applications. |
| **Scalability** | The pipeline is orchestrated on Kubernetes (AWS EKS) and can scale horizontally to handle thousands of samples. | Bioinformatics is a "big data" problem; solutions must be scalable. |
| **Automated Validation** | A comprehensive `nf-test` suite validates the pipeline at the unit, integration, and E2E (scientific) levels. | Proves the pipeline is not just technically functional but scientifically correct. |
| **DevOps & Automation** | A full GitHub Actions CI/CD pipeline automates the entire lifecycle from code change to deployment. | Demonstrates the ability to build and manage professional, automated systems. |
| **Cloud-Native Architecture** | The entire platform is designed to run on the cloud (AWS) and leverages cloud-native technologies like Kubernetes, ECR, and S3. | Shows proficiency in the modern cloud stack used by most biotech and pharma companies. |
| **Security** | Multi-stage Docker builds, non-root containers, and OIDC authentication are used to create a secure platform. | Essential for protecting sensitive patient data and intellectual property. |
| **Cost Optimization** | Terraform is used to provision spot instances for expensive compute tasks, significantly reducing costs. | Demonstrates business awareness and the ability to design cost-effective solutions. |

## How to Use This Repository

This repository is structured as a learning platform. The `docs/learning/` directory contains detailed, tutorial-style documentation on each of the core concepts.

1.  **[Learning Module 1: CI/CD for Production Bioinformatics](./docs/learning/01-ci-cd-for-bioinformatics.md)**
2.  **[Learning Module 2: Automated Testing for Bioinformatics Pipelines](./docs/learning/02-testing-for-bioinformatics.md)**
3.  **[Learning Module 3: Infrastructure as Code (IaC) with Terraform](./docs/learning/03-iac-with-terraform.md)**
4.  **[Learning Module 4: Enterprise Containerization with Docker](./docs/learning/04-containerization-with-docker.md)**

### Running the Pipeline

To run the pipeline, you will need Nextflow installed. The pipeline can be run with different profiles:

-   **Local Test (Docker):**

    ```bash
    nextflow run workflows/main.nf -profile test,docker
    ```

-   **Production (Kubernetes):**

    ```bash
    nextflow run workflows/main.nf -profile k8s
    ```

### Running the Tests

To run the automated test suite, you will need `nf-test` installed:

```bash
nf-test test
```

### Provisioning the Infrastructure

To provision the AWS infrastructure, you will need Terraform installed:

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

## Interview Talking Points

Each learning module contains specific "Interview Talking Points" that you can use to guide a conversation in a technical interview. The goal is not just to say "I built a pipeline," but to explain the engineering decisions and trade-offs you made, demonstrating a senior level of understanding.

For example:

-   Instead of saying "I used Docker," explain "I used multi-stage Docker builds to create optimized, minimal images, which reduces our security attack surface and improves deployment speed."
-   Instead of saying "I used AWS," explain "I used Terraform to provision a cost-optimized EKS cluster with a mix of on-demand and spot instances, which reduced our compute costs by over 70% for alignment workloads."
-   Instead of saying "I tested my pipeline," explain "I implemented a three-tiered testing strategy with unit, integration, and E2E scientific validation tests, using snapshot testing to ensure run-to-run reproducibility of the scientific outputs."
