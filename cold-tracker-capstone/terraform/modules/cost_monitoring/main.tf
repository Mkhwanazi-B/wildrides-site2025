resource "aws_s3_bucket" "cur" {
  bucket = var.cur_bucket_name
  force_destroy = true

  tags = {
    Name        = "CUR Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "cur_block" {
  bucket = aws_s3_bucket.cur.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
