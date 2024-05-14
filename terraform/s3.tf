resource "aws_s3_bucket" "backup_bucket" {
  bucket_prefix = "backups"
  # FIXME: could cause data loss
  # allow bucket to be destroyed if not empty
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "backup_bucket" {
  bucket                  = aws_s3_bucket.backup_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
