resource "aws_iam_role" "terraform_pull_request" {
  name = "GitHubActionsTerraformPullRequestRole"

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
            "token.actions.githubusercontent.com:sub" = ["repo:${var.repository}:pull_request"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_read_access" {
  name        = "TerraformStateReadAccess"
  description = "Allows read-only access to Terraform state"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "${var.s3_bucket_arn}/terraform/*" # To acquire and release locks
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*",
          "organizations:DescribeOrganization"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_pull_request_access" {
  role       = aws_iam_role.terraform_pull_request.name
  policy_arn = aws_iam_policy.terraform_read_access.arn
}

resource "aws_iam_role_policy_attachment" "terraform_pull_request_additional" {
  count = length(var.pull_request_policy_arns)

  role       = aws_iam_role.terraform_pull_request.name
  policy_arn = var.pull_request_policy_arns[count.index]
}
