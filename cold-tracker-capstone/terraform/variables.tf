variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "lambda_code_bucket" {
  description = "S3 bucket where Lambda zip file is stored"
  type        = string
}

variable "lambda_code_key" {
  description = "S3 key (file name) of the Lambda zip"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the IoT certificate"
  type        = string
}

# ✅ New Variable
variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}


