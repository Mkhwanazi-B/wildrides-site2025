variable "cur_bucket_name" {
  description = "S3 bucket name for CUR data"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the CloudWatch dashboard"
  type        = string
}
