# AWS IAM Permissions Fix Guide

## Problem
Your IAM user `bioinformatic-user` lacks permissions to create the Terraform backend resources (S3 bucket and DynamoDB table).

## Solution Options

### Option 1: Request IAM Policy from Administrator (RECOMMENDED)

Send this to your AWS administrator:

**Email Template:**
```
Subject: AWS IAM Policy Request for Terraform Infrastructure

Hi,

I need additional IAM permissions to deploy our bioinformatics infrastructure using Terraform.

Please attach the policy in the attached file `iam-policy-required.json` to my IAM user: 
arn:aws:iam::251214541935:user/bioinformatic-user

This will allow me to:
- Create S3 backend for Terraform state
- Create DynamoDB table for state locking
- Deploy EKS, ECR, VPC, and related AWS resources

Thank you!
```

**AWS Console Steps for Administrator:**
1. Go to IAM Console → Users → bioinformatic-user
2. Click "Add permissions" → "Attach policies directly"
3. Click "Create policy" → JSON tab
4. Paste contents from `iam-policy-required.json`
5. Name it: `TerraformBioinformaticsPlatform`
6. Attach to user

---

### Option 2: Manually Create Backend Resources

If you have AWS Console access but not CLI permissions:

**Create S3 Bucket:**
1. Go to S3 Console
2. Click "Create bucket"
3. Bucket name: `rnaseq-pipeline-tfstate-bucket`
4. Region: `us-east-1`
5. Enable "Bucket Versioning"
6. Enable "Default encryption" (SSE-S3)
7. Block all public access: ✓
8. Create bucket

**Create DynamoDB Table:**
1. Go to DynamoDB Console
2. Click "Create table"
3. Table name: `terraform-lock-table`
4. Partition key: `LockID` (String)
5. Billing mode: On-demand
6. Create table

After creating these manually, Terraform can use them.

---

### Option 3: Use AWS Administrator Credentials

If you have access to administrator credentials:

```powershell
# Configure with admin credentials
aws configure --profile admin

# Set profile for Terraform
$env:AWS_PROFILE="admin"

# Run bootstrap
terraform apply -auto-approve
```

---

## Next Steps After Fix

Once permissions are granted or resources are created:

```powershell
# 1. Run bootstrap (if not done manually)
cd terraform/bootstrap
terraform init
terraform apply -auto-approve

# 2. Initialize dev environment
cd ../environments/dev
terraform init
terraform plan
terraform apply
```
