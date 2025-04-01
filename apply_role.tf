resource "aws_iam_role" "terraform_apply" {
  name = "GitHubActionsTerraformApplyRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = ["repo:${var.repository}:ref:refs/heads/main"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_apply_access" {
  name        = "TerraformStateWriteAccess"
  description = "Allows access to Terraform state S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_apply_access" {
  role       = aws_iam_role.terraform_apply.name
  policy_arn = aws_iam_policy.terraform_apply_access.arn
}

resource "aws_iam_role_policy_attachment" "terraform_apply_additional" {
  count = length(var.apply_policy_arns)

  role       = aws_iam_role.terraform_apply.name
  policy_arn = var.apply_policy_arns[count.index]
}
