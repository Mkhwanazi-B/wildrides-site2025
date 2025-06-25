resource "aws_s3_bucket" "cur_reports" {
  bucket = var.cur_bucket_name

  tags = {
    Name        = "cur-report-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "cur_reports" {
  bucket = aws_s3_bucket.cur_reports.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cur_reports" {
  bucket = aws_s3_bucket.cur_reports.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {}  # Apply rule to the whole bucket

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cur_reports" {
  bucket = aws_s3_bucket.cur_reports.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
