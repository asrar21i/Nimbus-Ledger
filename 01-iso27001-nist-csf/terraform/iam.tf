resource "aws_iam_policy" "app_read_access" {
  name = "nimbus-app-read-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "rds_deletion_protection" {
  name = "nimbus-rds-deletion-protection"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = "rds:DeleteDBInstance"
        Resource = "arn:aws:rds:us-east-1:123456789012:db:nimbus-prod-db"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = "arn:aws:iam::123456789012:role/NimbusDBAdmins"
          }
        }
      }
    ]
  })
}