resource "aws_s3_bucket" "customer_docs" {
  bucket = var.bucket_name

  tags = {
    Owner              = "Engineering Lead"
    DataClassification = "Confidential"
    Environment        = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "customer_docs" {
  bucket = aws_s3_bucket.customer_docs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "customer_docs" {
  bucket = aws_s3_bucket.customer_docs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "customer_docs" {
  bucket = aws_s3_bucket.customer_docs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}