# Learning Module 1: CI/CD for Production Bioinformatics

## The "Why": From Manual Runs to Automated Production

In academic research, it's common to run bioinformatics pipelines manually from a terminal. For production environments in industry (clinical diagnostics, pharma), this approach is not scalable, reproducible, or safe. This is where **Continuous Integration, Continuous Delivery/Deployment (CI/CD)** becomes essential.

> **CI/CD** is a set of practices that automate the building, testing, and deployment of software. By automating these steps, teams can deliver reliable software faster.

For a bioinformatics pipeline, this means every time you change the code, an automated system validates your changes, tests the pipeline's scientific accuracy, and, if all tests pass, makes the new version available for use.

### Key Benefits for Bioinformatics

| Benefit | Why It Matters in Bioinformatics | How We Implemented It |
| :--- | :--- | :--- |
| **Reproducibility** | Scientific and clinical results *must* be reproducible. CI/CD ensures every run uses the exact same code, containers, and configuration. | Our GitHub Actions workflow pins versions for Nextflow, nf-test, and uses versioned Docker images. |
| **Quality & Reliability** | Bugs in pipelines can lead to incorrect scientific conclusions or, in a clinical setting, incorrect patient results. | We have a multi-stage CI pipeline: linting catches syntax errors, and `nf-test` validates scientific output. |
| **Velocity** | Automating testing and deployment allows bioinformaticians to develop and improve pipelines faster without fear of breaking production. | The workflow automatically builds containers, runs tests, and deploys, reducing manual effort from hours to minutes. |
| **Compliance (GxP, CAP/CLIA)** | In regulated environments, every change must be documented and validated. CI/CD provides an auditable trail of all changes, tests, and deployments. | The GitHub Actions logs serve as a record. Pull Requests with required reviews can be enforced for changes to `main`. |

---

## Our CI/CD Workflow: A Deep Dive

Our implementation is in `.github/workflows/pipeline-ci.yml`. It's designed to be a production-grade workflow that you can confidently discuss in interviews.

### Workflow Triggers

The workflow runs automatically on:
1.  **`push` to `main` or `master`**: When code is merged into the main branch, the full build, test, and deploy process is triggered.
2.  **`pull_request` to `main` or `master`**: When a developer proposes a change, the workflow runs the linting and testing jobs (but not deployment) to validate the change before it's merged.

This is a standard best practice known as **Trunk-Based Development** with branch protection.

### Job 1: `lint` - The First Line of Defense

This job is all about **fast feedback**. It runs in about one minute and catches the most common errors before any time-consuming jobs are started.

-   **`nextflow run main.nf -preview`**: This is a powerful Nextflow command that parses the entire pipeline and checks for syntax errors in the DSL2 code without actually running any tasks. It's a quick way to validate the pipeline's structure.
-   **`hadolint/hadolint-action`**: This action scans all our `Dockerfiles` for common mistakes and violations of best practices. For example, it will warn you if you forget to create a non-root user or if you have `apt-get update` in a separate layer from `apt-get install` (which can cause caching issues).

### Job 2: `build` - Creating Our Tools with Docker

This job is responsible for building our container images. It uses a **matrix strategy** to build all four containers (fastqc, star, salmon, multiqc) in parallel, significantly speeding up the workflow.

**Key Concept: OIDC Authentication with AWS**

Notice this step in the workflow:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ env.AWS_REGION }}
```

We are **not** using long-lived `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. Instead, we use **OpenID Connect (OIDC)**. This is a modern, secure way for GitHub Actions to authenticate with AWS.

1.  GitHub generates a temporary, unique token for the workflow run.
2.  It presents this token to AWS.
3.  AWS verifies the token is from your GitHub repository and grants temporary, short-lived credentials to the runner.

> **Interview Talking Point:** 
Using OIDC for authentication in CI/CD is a major security best practice. It eliminates the risk of leaked long-lived credentials, which is a common and serious security vulnerability. This demonstrates an understanding of enterprise-grade security.

### Job 3: `test` - Does the Science Work?

This is the most critical job for a bioinformatics pipeline. It runs our `nf-test` suite to ensure the pipeline is scientifically valid.

-   **`nf-test/setup-nf-test`**: Installs the `nf-test` framework.
-   **`./scripts/download-test-data.sh`**: Runs our script to fetch the small test dataset. In a real-world scenario, this might pull data from an S3 bucket.
-   **`nf-test test`**: Executes all the tests in the `tests/` directory.
-   **`EnricoMi/publish-unit-test-result-action`**: This action takes the test output and displays it beautifully in the GitHub Actions UI, making it easy to see which tests failed.

### Job 4: `deploy` - Going Live

This job only runs on a successful push to the `main` branch. It takes the validated pipeline infrastructure and applies it to our EKS cluster.

-   **`if: github.ref == 'refs/heads/main' ...`**: This condition ensures deployment only happens from the main branch.
-   **`environment: production`**: This links the job to a GitHub Environment, where you can set up protection rules (e.g., requiring manual approval before deploying to production).
-   **`kubectl apply`**: Applies our Kubernetes manifests (`k8s/*.yaml`) to the cluster, creating the namespace, roles, and storage needed for the pipeline.

### Job 5: `security` - Are We Vulnerable?

This final job runs a security scanner to look for known vulnerabilities in our code and dependencies.

-   **`aquasecurity/trivy-action`**: Trivy is a popular open-source security scanner. It scans our entire filesystem, including container definitions and application code, for Common Vulnerabilities and Exposures (CVEs).
-   **`github/codeql-action/upload-sarif`**: The results are uploaded in SARIF format to GitHub's Security tab, providing a centralized dashboard for viewing and managing vulnerabilities.

---

## Summary & Interview Talking Points

-   **You didn't just build a pipeline; you built a *pipeline platform*.** This includes automation for testing, validation, security, and deployment.
-   **You can explain the "why" behind each component.** You know why you used OIDC for security, why you used a matrix build for speed, and why you have different levels of testing.
-   **You understand the trade-offs.** For example, the CI pipeline takes longer to run than a manual execution, but the trade-off is massively increased reliability and reproducibility.
-   **You can connect engineering practices to scientific outcomes.** A well-tested pipeline produces trustworthy scientific results. A reproducible CI/CD workflow ensures experiments can be replicated.

This CI/CD workflow is a powerful demonstration of the skills required for a senior bioinformatics engineering role. Be prepared to walk through it in detail during an interview.
