output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.reports.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.reports.arn
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.reports.id
}
