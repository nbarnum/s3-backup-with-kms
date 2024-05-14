resource "aws_kms_key" "backup_key" {
  description = "s3-backups"
}

# give key an alias to avoid being named "-"
resource "aws_kms_alias" "backup_key" {
  name          = "alias/backup-key"
  target_key_id = aws_kms_key.backup_key.key_id
}

resource "aws_kms_key_policy" "backup_key" {
  key_id = aws_kms_key.backup_key.id
  # Policy copied from a key created via the console UI
  policy = jsonencode({
    Id      = "key-custompolicy-1"
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key",
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.s3_backup.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow attachment of persistent resources"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.s3_backup.arn
        }
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant",
        ]
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}
