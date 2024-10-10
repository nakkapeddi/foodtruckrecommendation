# s3_bucket.tf

# S3 Bucket for Application Artifacts
resource "aws_s3_bucket" "app_artifacts" {
  bucket = var.s3_bucket_name
  acl    = "private"

  # Enable server-side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "ElixirAppArtifacts"
    Environment = "Production"
  }
}

# Block Public Access Configuration
resource "aws_s3_bucket_public_access_block" "app_artifacts_block_public_access" {
  bucket                  = aws_s3_bucket.app_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Access Policy for EC2 instance
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.app_artifacts.arn,
      "${aws_s3_bucket.app_artifacts.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "EC2_S3_Access_Policy"
  description = "Policy to allow EC2 instance to access S3 bucket for application artifacts"
  policy      = data.aws_iam_policy_document.s3_access_policy.json
}