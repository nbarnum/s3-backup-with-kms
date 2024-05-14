# Look up account ID to build root user arn for KMS key policy
data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "allows3backupbucket" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.backup_bucket.arn}/*",
          "${aws_s3_bucket.backup_bucket.arn}",
        ]
      }

    ]
  })
}

data "aws_iam_policy_document" "allows3backupbucket" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

# not actually used here
resource "aws_iam_role" "s3_backup" {
  name                = "iam_s3_backup"
  assume_role_policy  = data.aws_iam_policy_document.allows3backupbucket.json
  managed_policy_arns = [aws_iam_policy.allows3backupbucket.arn]
}

resource "aws_iam_user" "s3_backup" {
  name = "s3_backup"
}

resource "aws_iam_user_policy_attachment" "s3_backup" {
  user       = aws_iam_user.s3_backup.name
  policy_arn = aws_iam_policy.allows3backupbucket.arn
}

# Warning: secret key gets written to state file
resource "aws_iam_access_key" "s3_backup" {
  user = aws_iam_user.s3_backup.name
}
