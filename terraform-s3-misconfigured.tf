# Intentionally Misconfigured S3 Bucket - FOR SECURITY TESTING ONLY
# This file contains multiple security misconfigurations and should NOT be used in production

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# Misconfigured S3 Bucket with public access
resource "aws_s3_bucket" "misconfigured_bucket" {
  bucket = "my-misconfigured-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "MisconfiguredBucket"
    Environment = "SecurityTesting"
    Purpose     = "Intentionally vulnerable for testing"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# MISCONFIGURATION 1: Public access block disabled (allows public access)
resource "aws_s3_bucket_public_access_block" "misconfigured_pab" {
  bucket = aws_s3_bucket.misconfigured_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# MISCONFIGURATION 2: Public read/write ACL
resource "aws_s3_bucket_acl" "misconfigured_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
  bucket     = aws_s3_bucket.misconfigured_bucket.id
  acl        = "public-read-write"
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.misconfigured_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# MISCONFIGURATION 3: No server-side encryption
# (Default encryption is intentionally not configured)

# MISCONFIGURATION 4: No versioning enabled
resource "aws_s3_bucket_versioning" "misconfigured_versioning" {
  bucket = aws_s3_bucket.misconfigured_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# MISCONFIGURATION 5: No access logging
# (Logging is intentionally not configured)

# MISCONFIGURATION 6: Public bucket policy allowing full access
resource "aws_s3_bucket_policy" "misconfigured_policy" {
  bucket = aws_s3_bucket.misconfigured_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadWrite"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.misconfigured_bucket.arn,
          "${aws_s3_bucket.misconfigured_bucket.arn}/*",
        ]
      },
    ]
  })
}

# Output the bucket name and URL
output "bucket_name" {
  value = aws_s3_bucket.misconfigured_bucket.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.misconfigured_bucket.bucket_domain_name
}

output "security_warnings" {
  value = "WARNING: This bucket is intentionally misconfigured with public access, no encryption, and no versioning!"
}

# Remediated S3 Buckets - Blocking Public Write Access
# These buckets are configured with proper security controls

# Secure S3 Bucket 1: ai-hackathon-test-bucket-2
resource "aws_s3_bucket" "secure_bucket_2" {
  bucket = "ai-hackathon-test-bucket-2"

  tags = {
    Name        = "SecureBucket2"
    Environment = "Production"
    Purpose     = "Secure bucket with public write access blocked"
  }
}

# Public Access Block for bucket 2 - BLOCKS all public access
resource "aws_s3_bucket_public_access_block" "secure_pab_2" {
  bucket = aws_s3_bucket.secure_bucket_2.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Private ACL for bucket 2
resource "aws_s3_bucket_acl" "secure_acl_2" {
  depends_on = [aws_s3_bucket_ownership_controls.secure_ownership_2]
  bucket     = aws_s3_bucket.secure_bucket_2.id
  acl        = "private"
}

resource "aws_s3_bucket_ownership_controls" "secure_ownership_2" {
  bucket = aws_s3_bucket.secure_bucket_2.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Secure S3 Bucket 2: ai-hackathon-test-bucket-3
resource "aws_s3_bucket" "secure_bucket_3" {
  bucket = "ai-hackathon-test-bucket-3"

  tags = {
    Name        = "SecureBucket3"
    Environment = "Production"
    Purpose     = "Secure bucket with public write access blocked"
  }
}

# Public Access Block for bucket 3 - BLOCKS all public access
resource "aws_s3_bucket_public_access_block" "secure_pab_3" {
  bucket = aws_s3_bucket.secure_bucket_3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Private ACL for bucket 3
resource "aws_s3_bucket_acl" "secure_acl_3" {
  depends_on = [aws_s3_bucket_ownership_controls.secure_ownership_3]
  bucket     = aws_s3_bucket.secure_bucket_3.id
  acl        = "private"
}

resource "aws_s3_bucket_ownership_controls" "secure_ownership_3" {
  bucket = aws_s3_bucket.secure_bucket_3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Output the secure bucket names
output "secure_bucket_2_name" {
  value = aws_s3_bucket.secure_bucket_2.id
}

output "secure_bucket_3_name" {
  value = aws_s3_bucket.secure_bucket_3.id
}
