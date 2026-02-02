# =============================================================================
# S3 Module - Reports Storage
# =============================================================================
#
# PURPOSE:
# Creates S3 buckets for storing pipeline results and reports
#
# WHAT THIS CREATES:
# 1. S3 bucket with versioning
# 2. Bucket lifecycle policies for cost optimization
# 3. Server-side encryption
# 4. Bucket policy for secure access
#
# =============================================================================

resource "aws_s3_bucket" "reports" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Purpose     = "RNA-Seq Pipeline Reports"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning for report history
resource "aws_s3_bucket_versioning" "reports" {
  bucket = aws_s3_bucket.reports.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access (security best practice)
resource "aws_s3_bucket_public_access_block" "reports" {
  bucket = aws_s3_bucket.reports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy: Archive old reports to save costs
resource "aws_s3_bucket_lifecycle_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id

  rule {
    id     = "archive-old-reports"
    status = "Enabled"

    # Move reports older than 30 days to Glacier
    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    # Delete reports older than 1 year
    expiration {
      days = 365
    }
  }

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    # Delete old versions after 90 days
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
