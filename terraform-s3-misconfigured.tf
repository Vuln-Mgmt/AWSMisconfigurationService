# S3 Bucket with Block Public Access Enabled - SECURED
# This file now has public write access blocked per AWS Security Hub control S3.3

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

# Secured S3 Bucket with Block Public Access enabled
resource "aws_s3_bucket" "misconfigured_bucket" {
  bucket = "my-secured-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "SecuredBucket"
    Environment = "SecurityTesting"
    Purpose     = "S3.3 remediation - public write access blocked"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# SECURED: Public access block enabled (blocks public write access)
resource "aws_s3_bucket_public_access_block" "misconfigured_pab" {
  bucket = aws_s3_bucket.misconfigured_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SECURED: Private ACL (no public access)
resource "aws_s3_bucket_acl" "misconfigured_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
  bucket     = aws_s3_bucket.misconfigured_bucket.id
  acl        = "private"
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

# SECURED: Public bucket policy removed to prevent public access
# (Bucket policy intentionally removed for security)

# Output the bucket name and URL
output "bucket_name" {
  value = aws_s3_bucket.misconfigured_bucket.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.misconfigured_bucket.bucket_domain_name
}

output "security_warnings" {
  value = "INFO: This bucket now has Block Public Access enabled. Public write access is blocked!"
}
