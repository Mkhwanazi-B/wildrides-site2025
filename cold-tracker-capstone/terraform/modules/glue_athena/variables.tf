variable "cur_bucket_name" {
  description = "S3 bucket where CUR reports are delivered"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
