output "cur_bucket_name" {
  description = "The name of the CUR S3 bucket"
  value       = aws_s3_bucket.cur_reports.bucket
}
