# S3 Reports Configuration

## Overview
Your pipeline now automatically uploads MultiQC reports to S3 for persistent storage and easy access.

## Setup Instructions

### 1. Deploy S3 Bucket with Terraform

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

This creates:
- **S3 Bucket**: `rnaseq-pipeline-reports`
- **Encryption**: AES256 at rest
- **Versioning**: Enabled for report history
- **Lifecycle**: 
  - Reports older than 30 days → Glacier (cost savings)
  - Reports older than 1 year → deleted
- **IAM Permissions**: GitHub Actions and EKS nodes can upload

### 2. Run Pipeline with S3 Upload

```bash
# Local execution
nextflow run workflows/main.nf \
  -profile docker \
  --reads "data/fastq/*_R{1,2}.fastq.gz" \
  --genome "data/reference/genome.fa" \
  --gtf "data/reference/genes.gtf" \
  --s3_bucket "rnaseq-pipeline-reports"

# On Kubernetes
nextflow run workflows/main.nf \
  -profile kubernetes \
  --reads "data/fastq/*_R{1,2}.fastq.gz" \
  --genome "data/reference/genome.fa" \
  --gtf "data/reference/genes.gtf" \
  --s3_bucket "rnaseq-pipeline-reports"
```

### 3. Access Reports from S3

```bash
# List all reports
aws s3 ls s3://rnaseq-pipeline-reports/reports/ --recursive

# Download specific report
aws s3 cp s3://rnaseq-pipeline-reports/reports/run_123/multiqc_report.html .

# Generate presigned URL (valid for 1 hour)
aws s3 presign s3://rnaseq-pipeline-reports/reports/run_123/multiqc_report.html --expires-in 3600

# Open the presigned URL in browser
start "https://rnaseq-pipeline-reports.s3.amazonaws.com/..."
```

## Report Organization

Reports are organized by run name and timestamp:
```
s3://rnaseq-pipeline-reports/
└── reports/
    ├── suspicious_turing_2024-01-15_10-30-45/
    │   ├── multiqc_report.html
    │   └── multiqc_data/
    ├── confident_einstein_2024-01-16_14-22-10/
    │   ├── multiqc_report.html
    │   └── multiqc_data/
    └── ...
```

## Cost Optimization

The S3 bucket includes lifecycle policies to minimize costs:

- **Standard Storage (0-30 days)**: Fast access, higher cost
- **Glacier (30-365 days)**: Archived, lower cost  
- **Deleted (>365 days)**: Removed automatically

**Estimated Costs**:
- MultiQC report: ~500 KB
- 100 reports/month: ~$0.01/month (Standard) + ~$0.004/month (Glacier)

## Security

- **Encryption**: All reports encrypted at rest with AES256
- **Access Control**: Only IAM users/roles with proper permissions can access
- **Public Access**: Blocked by default
- **Versioning**: Accidental deletions can be recovered

## GitHub Actions Integration

The CI/CD pipeline automatically sets `S3_REPORTS_BUCKET` environment variable. When tests run, reports are uploaded to S3 if the bucket exists.

## Troubleshooting

### Error: "Access Denied" when uploading

```bash
# Check IAM permissions
aws iam get-policy-version \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/rnaseq-pipeline-github-actions-policy \
  --version-id v1

# Should include S3 permissions for rnaseq-pipeline-reports bucket
```

### Error: "Bucket does not exist"

```bash
# Create the bucket with Terraform
cd terraform/environments/dev
terraform apply

# Or create manually
aws s3 mb s3://rnaseq-pipeline-reports --region us-east-1
```

### Reports not uploading automatically

```bash
# Check if s3_bucket parameter is set
nextflow run workflows/main.nf --help

# Verify AWS CLI is installed in container
docker run -it quay.io/biocontainers/multiqc:1.14 aws --version
```

## Enterprise Features

For production environments, consider:

1. **Cross-Region Replication**: Disaster recovery
2. **S3 Event Notifications**: Trigger downstream processing
3. **CloudWatch Metrics**: Monitor bucket usage
4. **AWS PrivateLink**: Access S3 without internet gateway
5. **S3 Access Logs**: Audit who accessed reports

## Example: Generate Report URL Programmatically

```python
import boto3
from datetime import datetime, timedelta

s3 = boto3.client('s3')

# Generate presigned URL valid for 24 hours
url = s3.generate_presigned_url(
    'get_object',
    Params={
        'Bucket': 'rnaseq-pipeline-reports',
        'Key': 'reports/run_123/multiqc_report.html'
    },
    ExpiresIn=86400  # 24 hours
)

print(f"Report URL: {url}")
```
