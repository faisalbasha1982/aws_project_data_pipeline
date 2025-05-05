resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-s3-sns-policy"
  description = "Lambda access to S3 and SNS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::event-announcement-site-bucket/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Subscribe",
          "sns:Publish"
        ],
        Resource = "*"
      }
    ]
  })
}

