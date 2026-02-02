variable "bucket_name" {
  description = "Name of the S3 bucket for reports"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}
