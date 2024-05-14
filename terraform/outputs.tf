output "s3_bucket_id" {
  value = aws_s3_bucket.backup_bucket.id
}

output "kms_key_arn" {
  value = aws_kms_key.backup_key.arn
}

output "aws_access_key_id" {
  value = aws_iam_access_key.s3_backup.id
}

# FIXME: secret key is written to outputs
output "aws_secret_access_key" {
  value = nonsensitive(aws_iam_access_key.s3_backup.secret)
}
