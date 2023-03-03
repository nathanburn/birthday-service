resource "aws_s3_bucket" "terraform_backend" {
  bucket = var.bucket_name
  # enable an object lock to avoid deletion or overwriting
  object_lock_enabled = true
  tags = {
    Name = "S3 Remote Terraform State Store"
  }
}

resource "aws_s3_bucket_acl" "terraform_backend_bucket_acl" {
  bucket = aws_s3_bucket.terraform_backend.id
  acl    = var.acl_value
}

resource "aws_s3_bucket_versioning" "terraform_backend_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_backend.id
  # enable versioning so that every revision of the state file is stored
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_backend_encryption" {
  bucket = aws_s3_bucket.terraform_backend.id
  # encrypt the contents of the bucket - as the state files contain sensitive data
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
