resource "aws_iam_policy" "policy" {
  name = "<env>policy"
  path = "/"
  description = "<env>-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}