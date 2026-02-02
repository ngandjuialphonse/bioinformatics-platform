# Quick Deployment Guide: S3 Reports Feature

## What Changed

Your pipeline now automatically uploads MultiQC HTML reports to S3 for persistent storage and easy access. This solves the problem of reports being stuck in Kubernetes pods.

## Files Modified

1. **workflows/nextflow.config** - Added `s3_bucket` and `s3_prefix` parameters
2. **workflows/main.nf** - Added S3 upload logic in `workflow.onComplete`
3. **.github/workflows/pipeline-ci.yml** - Added `S3_REPORTS_BUCKET` environment variable
4. **terraform/modules/s3/** - New module for S3 bucket with lifecycle policies
5. **terraform/modules/iam/** - Updated to grant S3 permissions
6. **terraform/environments/dev/main.tf** - Added S3 module instantiation

## Deployment Steps

### Step 1: Apply Terraform Changes

```powershell
cd terraform\environments\dev

# Review the changes
terraform plan

# Apply (creates S3 bucket + IAM permissions)
terraform apply
```

**Expected Output:**
```
Plan: 6 to add, 1 to change, 0 to destroy

Changes:
  + module.s3_reports.aws_s3_bucket.reports
  + module.s3_reports.aws_s3_bucket_versioning.reports
  + module.s3_reports.aws_s3_bucket_lifecycle_configuration.reports
  + module.s3_reports.aws_s3_bucket_encryption.reports
  + module.s3_reports.aws_s3_bucket_public_access_block.reports
  ~ module.iam.aws_iam_policy.github_actions_policy (S3 permissions added)
```

### Step 2: Get the S3 Bucket Name

```powershell
terraform output s3_reports_bucket
```

Should show: `rnaseq-pipeline-reports`

### Step 3: Test Locally (Optional)

```bash
cd workflows

nextflow run main.nf \
  -profile test,docker \
  --s3_bucket "rnaseq-pipeline-reports"
```

### Step 4: Push Changes to GitHub

```bash
git add .
git commit -m "Add S3 upload for MultiQC reports"
git push origin main
```

GitHub Actions will automatically:
1. Build containers
2. Run tests
3. Deploy to Kubernetes
4. Upload reports to S3 (if tests generate them)

## How to Access Reports

### Method 1: AWS Console
1. Go to https://console.aws.amazon.com/s3/
2. Navigate to `rnaseq-pipeline-reports/reports/`
3. Find your run by timestamp
4. Download `multiqc_report.html`

### Method 2: AWS CLI
```bash
# List all reports
aws s3 ls s3://rnaseq-pipeline-reports/reports/ --recursive

# Download specific report
aws s3 cp s3://rnaseq-pipeline-reports/reports/<run_name>/multiqc_report.html .

# Generate presigned URL (valid for 1 hour)
aws s3 presign s3://rnaseq-pipeline-reports/reports/<run_name>/multiqc_report.html --expires-in 3600
```

### Method 3: From Nextflow Output
After pipeline completes, the summary will show:
```
Reports:
  MultiQC:    ./results/multiqc_report.html

S3 Location:
  s3://rnaseq-pipeline-reports/reports/silly_euler_2024-02-01_15-30-45/multiqc_report.html
  (Generate presigned URL: aws s3 presign <url> --expires-in 3600)
```

## Cost Estimate

**S3 Storage Costs (us-east-1):**
- Standard Storage (0-30 days): $0.023/GB/month
- Glacier (30-365 days): $0.004/GB/month
- MultiQC report size: ~500 KB

**Example:**
- 100 reports/month = 50 MB
- Cost: ~$0.001/month Standard + ~$0.0002/month Glacier
- **Total: < $0.01/month**

## Enterprise Features

✅ **Versioning**: Enabled - recover accidentally deleted reports  
✅ **Encryption**: AES256 at rest  
✅ **Lifecycle**: Automatic archival to Glacier after 30 days  
✅ **Access Control**: IAM-based, no public access  
✅ **Cost Optimized**: Reports auto-deleted after 1 year  

## Troubleshooting

### "Access Denied" Error
```bash
# Check IAM permissions
aws iam get-user

# Should be: bioinformatic-user with admin permissions
# Or: GitHub Actions IAM role with S3 policy attached
```

### "Bucket Does Not Exist"
```bash
# Verify bucket was created
aws s3 ls | grep rnaseq-pipeline-reports

# If not found, run terraform apply again
cd terraform/environments/dev
terraform apply
```

### Reports Not Uploading
Check Nextflow output for:
```
Uploading reports to S3: s3://rnaseq-pipeline-reports/...
✓ Reports uploaded successfully to S3
```

If you see `⚠ Failed to upload to S3`, check:
1. AWS credentials are configured (`aws configure`)
2. IAM permissions include S3 PutObject
3. Bucket name is correct in `--s3_bucket` parameter

## Next Steps

For production use, consider:
- Setting up CloudWatch alarms for bucket size
- Enabling S3 access logging for compliance
- Creating CloudFront distribution for faster downloads
- Setting up S3 event notifications to trigger downstream analysis

See **[docs/S3_REPORTS_SETUP.md](./S3_REPORTS_SETUP.md)** for detailed documentation.
