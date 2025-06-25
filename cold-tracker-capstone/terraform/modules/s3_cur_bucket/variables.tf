variable "cur_bucket_name" {
  description = "Name of the S3 bucket for CUR reports"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}
