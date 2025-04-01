data "aws_organizations_organization" "current" {}

resource "aws_iam_role" "terraform_pull_request_assume" {
  name = "TerraformPullRequestAssumeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      length(var.pull_request_role_arns) > 0 ? [
        {
          Effect = "Allow"
          Principal = {
            AWS = var.pull_request_role_arns
          }
          Action = "sts:AssumeRole"
        }
      ] : [],
      [
        {
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Action = "sts:AssumeRole"
          Condition = {
            StringEquals = {
              "aws:PrincipalOrgID" : data.aws_organizations_organization.current.id
            }
          }
        }
      ]
    )
  })
}

resource "aws_iam_role_policy_attachment" "terraform_pull_request_assume_access" {
  role       = aws_iam_role.terraform_pull_request_assume.name
  policy_arn = aws_iam_policy.terraform_read_access.arn
}

resource "aws_iam_role_policy_attachment" "terraform_pull_request_assume_policies" {
  count = length(var.pull_request_policy_arns)

  role       = aws_iam_role.terraform_pull_request_assume.name
  policy_arn = var.pull_request_policy_arns[count.index]
}
