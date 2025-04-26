# ======================================================
# S3
# ======================================================

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.aws_region}-${var.environment}-s3"
  force_destroy = true
  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "s3" {
  bucket                  = aws_s3_bucket.s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3" {
  bucket = aws_s3_bucket.s3.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "s3" {
  bucket = aws_s3_bucket.s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3.id}",
          "arn:aws:s3:::${aws_s3_bucket.s3.id}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalArn" = "arn:aws:iam::${local.aws_account_id}:root"
          }
        }
      }
    ]
  })
}
